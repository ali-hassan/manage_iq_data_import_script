puts "Started Parsing"
require 'smarter_csv'
require "byebug"


data = File.open("updated_sheet_final_version.csv")
index = 0;

require "uri"
require "net/http"

#response = https.request(request)
#puts response.read_body

puts "Get all columns of CSV"

CSV.foreach("updated_sheet_final_version.csv").map do |row|
  puts "Row wise #{row}********************"


  row.each do |col_val|
    cat_name = col_val

    # url = URI("https://172.31.211.137/api/categories")
    # https = Net::HTTP.new(url.host, url.port)
    # https.use_ssl = true
    # request = Net::HTTP::Post.new(url)
    # request["Authorization"] = "Basic YWRtaW46V1NYUUFaQDY1NSNAIQ=="
    # request["Content-Type"] = "text/plain"
    # request.body = "{\r\n  \"name\" : \"#{cat_name.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{cat_name}\"\r\n}"


    response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST 'https://172.31.211.137/api/categories' \
                   --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
                   --header 'Content-Type: text/plain'\
                   --data-raw '{
                   "name" : "#{cat_name.downcase.tr(" ", "_")}",
                  "description" : "#{cat_name}"
                 }'`
    get_re= #`curl -v -k -u admin:WSXQAZ@655#@! --location --request GET 'https://172.31.211.137/api/categories/344'`
    puts response.read_body
    category_id = response.read_body["id"]
    debugger




    response = https.request(request)
    puts response.read_body
    category_id = response.read_body["id"]

    unless category_id.present?
      # url = URI("https://172.31.211.137/api/categories")
      #
      # https = Net::HTTP.new(url.host, url.port)
      # https.use_ssl = true
      #
      # request = Net::HTTP::Get.new(url)
      # request["Authorization"] = "Basic YWRtaW46V1NYUUFaQDY1NSNAIQ=="
      # request["Content-Type"] = "text/plain"
      # request.body = "{\r\n  \"name\" : \"#{cat_name.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{cat_name}\"\r\n}"

      categories = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET 'https://172.31.211.137/api/categories'`
      categories.map do |cat|
        puts cat
      end
      puts response.read_body
      category_id = response.read_body["id"]
    end

    # Remove first element of the array

    CSV.parse(File.open('updated_sheet_final_version.csv'), headers: true).by_col[col_val].each do |val|

      url = URI("https://172.31.211.137/api/categories/#{category_id}/tags")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Basic YWRtaW46V1NYUUFaQDY1NSNAIQ=="
      request["Content-Type"] = "text/plain"
      request.body = "{\r\n  \"name\" : \"#{val.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{val}\"\r\n}"

      response = https.request(request)
      puts response.read_body
    end

  end
end

puts "End Parsing"

