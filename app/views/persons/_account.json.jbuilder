
json.set! '@id', '#' + simplify_fedora_id(account['account_ssim'].first)
json.set! '@type', 'foaf:OnlineAccount'
json.set! 'dc:title', account['title_tesi']
json.set! 'foaf:accountName', account['account_name_tesi']
json.set! 'foaf:accountServiceHomepage', account['account_service_homepage_tesi']
