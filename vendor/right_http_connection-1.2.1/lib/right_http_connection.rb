#
# Copyright (c) 2007-2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module Rightscale
  class HttpConnection 
    def request(request_params, &block)
      loop do
        # if we are inside a delay between retries: no requests this time!
        if error_count > HTTP_CONNECTION_RETRY_COUNT \
        && error_time + HTTP_CONNECTION_RETRY_DELAY > Time.now
          @logger.warn("#{err_header} re-raising same error: #{banana_message} " +
                      "-- error count: #{error_count}, error age: #{Time.now.to_i - error_time.to_i}")  
          exception = get_param(:exception) || RuntimeError
          raise exception.new(banana_message)
        end
      
        # try to connect server(if connection does not exist) and get response data
        begin
          request_params[:protocol] ||= (request_params[:port] == 443 ? 'https' : 'http')
          # (re)open connection to server if none exists or params has changed
          unless @http          && 
                 @http.started? &&
                 @server   == request_params[:server] &&
                 @port     == request_params[:port]   &&
                 @protocol == request_params[:protocol]
            start(request_params)
          end
          
          # get response and return it
          request  = request_params[:request]
          request['User-Agent'] = get_param(:user_agent) || ''

          # Detect if the body is a streamable object like a file or socket.  If so, stream that
          # bad boy.
          if(request.body && request.body.respond_to?(:read))
            body = request.body
            request.content_length = if body.respond_to?(:lstat) then
              body.lstat.size
            elsif body.respond_to?(:stat) then
              body.stat.size
            elsif body.respond_to?(:length) then
              body.length
            elsif body.respond_to?(:size) then
              body.size
            else
              raise "Cannot determine request's Content-Length header for #{body.inspect}.  #{body} doesn't respond to #lstat, #stat, #length or #size."
            end
            request.body_stream = request.body
          end
          response = @http.request(request, &block)
          
          error_reset
          eof_reset
          return response

        # We treat EOF errors and the timeout/network errors differently.  Both
        # are tracked in different statistics blocks.  Note below that EOF
        # errors will sleep for a certain (exponentially increasing) period.
        # Other errors don't sleep because there is already an inherent delay
        # in them; connect and read timeouts (for example) have already
        # 'slept'.  It is still not clear which way we should treat errors
        # like RST and resolution failures.  For now, there is no additional
        # delay for these errors although this may change in the future.
        
        # EOFError means the server closed the connection on us.
        rescue EOFError => e
          @logger.debug("#{err_header} server #{@server} closed connection")
          @http = nil
          
            # if we have waited long enough - raise an exception...
          if raise_on_eof_exception?
            exception = get_param(:exception) || RuntimeError
            @logger.warn("#{err_header} raising #{exception} due to permanent EOF being received from #{@server}, error age: #{Time.now.to_i - eof_time.to_i}")  
            raise exception.new("Permanent EOF is being received from #{@server}.")
          else
              # ... else just sleep a bit before new retry
            sleep(add_eof)
          end 
        rescue Exception => e  # See comment at bottom for the list of errors seen...
          @http = nil
          # if ctrl+c is pressed - we have to reraise exception to terminate proggy 
          if e.is_a?(Interrupt) && !( e.is_a?(Errno::ETIMEDOUT) || e.is_a?(Timeout::Error))
            @logger.debug( "#{err_header} request to server #{@server} interrupted by ctrl-c")
            raise
          elsif e.is_a?(ArgumentError) && e.message.include?('wrong number of arguments (5 for 4)')
            # seems our net_fix patch was overriden...
            exception = get_param(:exception) || RuntimeError
            raise exception.new('incompatible Net::HTTP monkey-patch')
          end
          # oops - we got a banana: log it
          error_add(e.message)
          @logger.warn("#{err_header} request failure count: #{error_count}, exception: #{e.inspect}")
        end
      end
    end
  end
end
