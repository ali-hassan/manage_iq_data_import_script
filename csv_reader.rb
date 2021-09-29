puts "Started Parsing"
require 'smarter_csv'
require 'logger'
require "byebug"


puts "Get all columns of CSV"

CSV.foreach("final_version_of_csv.csv").map do |row|
  puts "Row wise #{row}********************"


  row.each do |col_val|
    cat_name = col_val
    category_id = nil
    cat_name_val = cat_name.downcase.gsub(/[^0-9A-Za-z]/, '_')
    response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST 'https://172.31.211.137/api/categories' \
                   --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
                   --header 'Content-Type: text/plain'\
                   --data-raw '{
                   "name" : "#{cat_name_val}",
                  "description" : "#{cat_name}"
                 }'`
    response = JSON.parse(response)
    puts "response is pasted here *******************************************************"
    puts "response is = #{response}"
    is_error =  response["error"]
    category_id = response["id"] unless is_error

    if is_error
      all_categories = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET 'https://172.31.211.137/api/categories'`
      puts "categories registered alread"
      puts "searching appropiate category"
      categories = JSON.parse(all_categories)

      categories["resources"].map do |cat|
        response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET "#{cat["href"]}" \
            --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
            --header 'Content-Type: text/plain' \
           --data-raw '{
           "name" : "#{cat_name_val}",
          "description" : "#{cat_name}"
          }'`
        response = JSON.parse(response)
        if response["description"] == cat_name
          puts "Relvant category found successfully and its matched"
          puts "category is #{response["description"]}"
          category_id = response["id"]
          puts "categories found."
          break
        end
      end

      CSV.parse(File.open('updated_sheet_final_version.csv'), headers: true).by_col[col_val].each do |val|
        #request.body = "{\r\n  \"name\" : \"#{val.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{val}\"\r\n}"
        tag_name = val
        tag_name = val.downcase.gsub!(/[^0-9A-Za-z]/, '_') unless cat_name_val == "sr_no"
        puts "tag_name is=#{tag_name}*********************************************************************************"
        response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "https://172.31.211.137/api/categories/#{category_id}/tags" \
     --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
     --header 'Content-Type: text/plain' \
     --data-raw '{
      "name" : "#{tag_name}",
     "description" : "#{val}"
    }'`
        response = JSON.parse(response)
        puts "*********************************Tag response =#{response}**********************"
        if response["error"]
          puts "Tag creation error is below:"
          puts response[:error]
        end
      end
    else
      CSV.parse(File.open('updated_sheet_final_version.csv'), headers: true).by_col[col_val].each do |val|
        #request.body = "{\r\n  \"name\" : \"#{val.downcase.tr(" ", "_")}\",\r\n  \"description\" : \"#{val}\"\r\n}"
        puts "***************************************************************************************************************************"
        puts "category_id=#{category_id}"
        puts "****************************************************************************************************************************"

        response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "https://172.31.211.137/api/categories/#{category_id}/tags" \
       --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
       --header 'Content-Type: text/plain' \
       --data-raw '{
        "name" : "#{val.downcase.tr(" ", "_")}",
       "description" : "#{val}"
      }'`
        response = JSON.parse(request)
        puts "********************************************************************************************************************************"
        puts "response of tag is=#{response}"
        if response["error"]
          puts "Tag creation error is below:"
          puts response[:error]
        end
      end

    end

  end
end

puts "End Parsing"
