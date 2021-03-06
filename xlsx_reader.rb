puts "Started Parsing"
require 'logger'
require "byebug"
require "roo"
require 'json'

puts "Get all columns of xlsx"
# name of file for example inventory, place it on same level
xlsx = Roo::Spreadsheet.open('./hostnames.xlsx')
URL = Rails.env = "production" ? "https://172.31.211.137" : ""

headers = Hash.new
xlsx.row(1).each_with_index {|header,i|
  headers[header] = i
}

categories = xlsx.sheet(0).row(1)
# Headers
# ["Change Control ", "DA/Legacy", "Zone/VLAN", "OS Type", "OS Version", "Environment", "Host Name", "DNS Name", "Domain", "Production IP", "Management IP", "Secondary IP", "Virtual  IP", "ILO IP", "Status", "Function/Service", "Function Types", "Asset Type", "Asset Owner", "Department", "Hardware \nCategory", "Serial Number", "Manfucaturer", "Model", "TP Counter Part", "OSQ"]

categories.each do |category|
  col_val = category
  cat_name = category.strip
  category_id = nil
  cat_name_val = cat_name.downcase.gsub(/[^0-9A-Za-z]/, '_')

  response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "#{URL}/api/categories" \
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
    all_categories = `curl -v -k -u admin:WSXQAZ@655#@! --location --request GET "#{URL}/api/categories"`
    puts "categoq3e56789i
-ries registered alread"
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
    column_data = []
    ((xlsx.first_row + 1)..xlsx.last_row).each do |row|
      # Get the column data using the column heading.
      column_data.push(xlsx.row(row)[headers[col_val]])
    end


    column_data.each do |val|
      tag_name = val
      if cat_name_val == "change_control"
        tag_name = tag_name.to_s.gsub!(/[^0-9A-Za-z]/, '_')
      end
      tag_name = tag_name.to_s.downcase.gsub(/[^0-9A-Za-z]/, '_') unless cat_name_val == "sr_no" || cat_name_val == "change_control"
      puts "tag_name is=#{tag_name}*********************************************************************************"
      response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "#{URL}/api/categories/#{category_id}/tags" \
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

    column_data = []
    ((xlsx.first_row + 1)..xlsx.last_row).each do |row|
      # Get the column data using the column heading.
      column_data.push(xlsx.row(row)[headers[col_val]])
    end

    column_data.uniq.each do |val|
      val_name = val
      val_name = val.downcase.gsub(/[^0-9A-Za-z]/, '_') unless cat_name_val == "sr_no"
      puts "category_id=#{category_id}***************************************************************************************************************************"
      puts "tag_name= #{val_name}"
      puts "description= #{val}"
      response = `curl -v -k -u admin:WSXQAZ@655#@! --location --request POST "#{URL}/api/categories/#{category_id}/tags" \
       --header 'Authorization: Basic YWRtaW46V1NYUUFaQDY1NSNAIQ==' \
       --header 'Content-Type: text/plain' \
       --data-raw '{
        "name" : "#{val_name}",
       "description" : "#{val}"
      }'`
      response = JSON.parse(response)
      puts "response of tag is=#{response}          ****************************************"
      if response["error"]
        puts "Tag creation error is below:"
        puts response[:error]
      end
    end
  end
end

puts "End Parsing"
