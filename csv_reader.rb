puts "Started Parsing"
require 'smarter_csv'
require "byebug"


data = File.open("updated_sheet_final_version.csv")
index = 0;

puts "Get all columns of CSV"

CSV.foreach("updated_sheet_final_version.csv").map do |row|
  puts "Row wise #{row}********************"


  row.each do |col_val|
    cat_name = col_val
    category_id = nil

    response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST 'https://172.31.211.137/api/categories' \
                   --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
                   --header 'Content-Type: text/plain'\
                   --data-raw '{
                   "name" : "#{cat_name.downcase.tr(" ", "_")}",
                  "description" : "#{cat_name}"
                 }'`
    response = eval(response)
    is_error =  response[:error]
    category_id = response[:id] unless is_error

    if is_error
      categories = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET 'https://172.31.211.137/api/categories'`
      puts "categories registered alread"
      puts "searching appropiate category"
      eval(categories)[:resources].map do |cat|
        response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET "cat[:href]" \
            --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
            --header 'Content-Type: text/plain' \
           --data-raw '{
           "name" : "test",
          "description" : "Test Category"
          }'`
        response = eval(response)
        
        if response[:description] == cat_name
          puts "Relvant category found successfully and its matched"
          puts "category is #{response[:description]}"
          category_id = response[:id]
          break
        end
      end
      CSV.parse(File.open('updated_sheet_final_version.csv'), headers: true).by_col[col_val].each do |val|
        #request.body = "{\r\n  \"name\" : \"#{val.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{val}\"\r\n}"
        response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "https://172.31.211.137/api/categories/#{category_id}/tags" \
       --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
       --header 'Content-Type: text/plain' \
       --data-raw '{
        "name" : "#{val.downcase.tr(" ", "_")}",
       "description" : "#{val}"
      }'`
        response = eval(request)
        if response[:error]
          puts "Tag creation error is below:"
          puts response[:error]
        end
      end

    end
  end
end

puts "End Parsing"

