
creator_uri = person_url(id: FedoraID.shorten(work['creator_id_ssi']))

json.set! '@type', 'bibo:Document'
json.set! '@id', work_url(id: FedoraID.shorten(work['id']))
json.set! 'dc:title', work['title_tesi']
json.set! 'bibo:authorList', work['author_list_tesim'] || []
json.set! 'dc:date', work['date_dtsi'] || ''
json.set! 'dc:abstract', work['abstract_tesi'] || ''
json.set! 'dc:isPartOf', "#{creator_uri}/works" 
json.set! 'dc:bibliographicCitation',  work['bibliographic_citation_ss'] || ''
json.set! 'dc:subject', work['subject_tesim'] || []
json.set! 'dc:creator', creator_uri
json.set! 'dc:type',    work['doc_type_tesi']

if full
  json.set! 'bibo:doi', work['doi_tesi'] || ''
  json.set! 'bibo:uri', work['canonical_uri_ssm'] || []
  json.set! 'bibo:volume', work['volume_ss'] || ''
  json.set! 'bibo:issue', work['issue_ss'] || ''
  json.set! 'bibo:number', work['number_ss'] || ''
  json.set! 'bibo:pages', work['pages_ss'] || ''
  json.set! 'bibo:pageStart', work['page_start_ss'] || ''
  json.set! 'bibo:pageEnd', work['page_end_ss'] || ''
  json.set! 'dc:publisher', work['publisher_ss'] || ''
end
