pages=()

end_of_url='\/([^\/]){1,}$'
full_meta_tags='\<meta([^\<\>]){1,}\>'

relevant_results1='(.){0,}("description"|"title"|"og:.{0,}"|title=".{0,}")(.){0,}'
relevant_results2='(.){0,}("twitter:)(.){0,}'

property_att='(property="|name="|title=")([^"]{0,}")'
content_att='(content=")([^"]{0,}")'
att_combined='((property="|name="|title=")[^"]{0,}"(?:.*)((content=")[^"]{0,}")?)|(((content=")[^"]{0,}")?(?:.*)(property="|name="|title=")[^"]{0,}")'

while read -r line; do
  page=$(echo "$line" | grep -Po "${end_of_url}")
  page=$(echo "${page:1:${#page}}")
  page=$(echo "$page.txt")

  #wget -nd --output-document="$page" -A .html $line
  pages=(${pages[@]} "$page")

done < andalucia_links.txt

result_file_name="meta_data.csv"
(echo "Meta Data File" && echo "") > $result_file_name

for i in "${pages[@]}"; do
  # Grab page content
  current=$(<$i)

  # Get only meta tags from content and duplicate
  content=$(echo "$current" | grep -Po "${full_meta_tags}")
  content2=("${content[@]}")

  # Keep only the desired meta tags
  content=$(echo "$content" | grep -Po "${relevant_results1}")
  content2=$(echo "$content2" | grep -Po "${relevant_results2}")

  # Pre Condensing Test
  #(echo "$i" && echo "" && echo "$content" && echo "" && echo "$content2" && echo "" && echo "") >> $result_file_name

  # Condense and order attributes (content)
  content_tmp=()
  while  read line; do
    catch1=$(echo "$line" | grep -Po "${property_att}")
    catch2=$(echo "$line" | grep -Po "${content_att}")
    content_tmp=("${content_tmp[@]}" "${catch1}, ${catch2}")

  done <<< "$content"
  content_tmp=$(sort <<<"${array[*]}")

  # Page title
  (echo "$i," && echo "") >> $result_file_name

  # Print (content)
  for i in "${content_tmp[@]}"; do
    echo "$i," >> $result_file_name
  done

  # Spacer
  (echo ",") >> $result_file_name

  # Condense and order attributes (content)
  content_tmp=()
  while  read line; do
    catch1=$(echo "$line" | grep -Po "${property_att}")
    catch2=$(echo "$line" | grep -Po "${content_att}")
    content_tmp=("${content_tmp[@]}" "${catch1}, ${catch2}")

  done <<< "$content2"
  content_tmp=$(sort <<<"${array[*]}")

  # Print (content)
  for i in "${content_tmp[@]}"; do
    echo "$i," >> $result_file_name
  done

  # double Spacer
  (echo "," && echo ",") >> $result_file_name

done
