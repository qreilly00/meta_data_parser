pages=()

end_of_url='\/([^\/]){1,}$'
full_meta_tags='\<meta([^\<\>]){1,}\>'

relevant_results1='(.){0,}("description"|"title"|"og:)(.){0,}'
relevant_results2='(.){0,}("twitter:)(.){0,}'

property_att='(property="|name=")([^"]{1,}")'
content_att='(content=")([^"]{1,}")'




while read -r line; do
  page=$(echo "$line" | grep -Po "${end_of_url}")
  page=$(echo "${page:1:${#page}}")
  page=$(echo "$page.txt")

  #wget -nd --output-document="$page" -A .html $line
  pages=(${pages[@]} "$page")

done < andalucia_links_tmp.txt

result_file_name="meta_data.txt"
(echo "Meta Data File" && echo "") > $result_file_name

for i in "${pages[@]}"; do
  current=$(<$i)

  content=$(echo "$current" | grep -Po "${full_meta_tags}")
  content2=$(echo "$content" | grep -Po "${relevant_results2}")

  content=$(echo "$content" | grep -Po "${relevant_results1}")
  content=$(sort <<< "${content[*]}")

  content2=$(sort <<< "${content2[*]}")


  (echo "$i" && echo "" && echo "$content" && echo "" && echo "$content2" && echo "" && echo "") >> $result_file_name

done
