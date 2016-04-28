/*
 *  Project: Linked Name Authority Gateway
 *  Description: jquery plugin to mediate LDP-style communications with the
 *    Linked Name Authority server.
 *  Author: John Bell (@nmdjohn), Dartmouth College
 *  License: MIT License ( https://opensource.org/licenses/MIT )
 */

;(function ($, window, document, undefined){

	'use strict';

	var pluginName = "LNAGateway";
	var dataKey = "plugin_" + pluginName;

	/*
	 * LNAGateway plugin
	 */
	var Plugin = function (options){
	    //defaults
	    this.defaults = {
	      'baseURL': _base_url,    							 //defined in config or elsewhere, trailing slash required. In view, for LNA
	      'lnaVersion': '0.2.0',
	      'authenticity_token': true                         //whether or not to add auth token field to all queries
	    };
	    this.options = this.defaults;
	    this.errors = [];

	    /*
	     * For all forms, data-lna-query must be set to a key in this array
	     *
	     * For templates, the given keys will always appear in submitted forms.
	     * Any null keys in a data array that the user tries to submit will
	     * cause that submission to be blocked, so a template key set to "" below
	     * is optional while a key set to null is not.
	     *
	     */
	    this.queries = {
	    	'listPersons':{'method': 'GET', 'path': 'persons/', 'template': {}
	    				},
	    	'listOrgs':{'method': 'GET', 'path': 'organizations/', 'template': {}
	    				},	    
	    	'listWorks':{'method': 'GET', 'path': 'works/', 'template': {}
	    				},	    								
			'loadPerson': {'method': 'GET', 'path': 'person/', 'template': {}
	    				},
			'loadOrg': 	{'method': 'GET', 'path': 'organization/', 'template': {}
	    				},
			'loadWork': {'method': 'GET', 'path': 'work/', 'template': {}
	    				},	    				  				
			'loadPersonWorks': {'method': 'GET', 'path': 'person/', 'template': {}
	    				},
	    	'findOrgs':   {'method': 'POST', 'path': 'organizations/', 'template':{
	    				  'skos:prefLabel': '',
	    				  'skos:altLabel': '',
	    				  'org:subOrganizationOf': ''}
	    				},
	    	'findOrgPersons': {'method': 'POST', 'path': 'persons/', 'template':{
	    				  'foaf:name': '',
	    				  'foaf:givenName': '',
	    				  'foaf:familyName': '',
	    				  'org:member': ''}
	    				},	
	    	'findPersons': {'method': 'POST', 'path': 'persons/', 'template':{
	    				  'foaf:name': '',
	    				  'foaf:givenName': '',
	    				  'foaf:familyName': '',
	    				  'org:member': ''}
	    				},
	    	'findWorks': {'method': 'POST', 'path': 'works/', 'template':{
	    				  'bibo:authorList': '',
	    				  'bibo:doi': '',
	    				  'dc:title': '',
	    				  'org:member': '',
	    				  'dc:abstract': ''}
	    				},	    				
			'newOrg':     {'method': 'POST', 'path': 'organization/', 'template': {
	                      "org:identifier": null,
	                      "skos:prefLabel": null,
	                      "skos:altLabel": [],
	                      "owltime:hasBeginning": null,
	                      "owltime:hasEnd": ""}
	                    },
	     	'newPerson':  {'method': 'POST', 'path': 'person/', 'template': {
	                      "foaf:name": null,
	                      "foaf:givenName": null,
	                      "foaf:familyName": null,
	                      "foaf:title": "",
	                      "foaf:image": "",
	                      "foaf:homepage": [],	                      
	                      "foaf:mbox": null,
	                      "org:reportsTo": null}
	                    },	                    
	        'newWork': 	  {'method': 'POST', 'path': 'work/', 'template': {
	        			  'dc:title': null,
	        			  'bibo:authorList': null,
	        			  'dc:abstract': null,
	        			  'bibo:doi': '',
	        			  'dc:date': '',
	        			  'bibo:uri': [],
	        			  'bibo:volume': '',
	        			  'bibo:pages': '',
	        			  'bibo:pageStart': '',
	        			  'bibo:pageEnd': '',
	        			  'dc:publisher': '',
	        			  'dc:subject': [],
	        			  'dc:bibliographicCitation': '',
	        			  'dc:creator': null}
	        			},
	        'newLicense': {'method': 'POST', 'path': 'work/', 'template':{
	        			  'dc:title': null,
	        			  'dc:description': null,
	        			  'ali:start_date': null,
	        			  'ali:end_date': '',
	        			  'ali:uri': ''}
	        			},        			
	        'newAffiliation': {'method': 'POST', 'path': 'person/', 'template':{
	        			  'org:organization': null,
	        			  'vcard:email': '',
	        			  'vcard:title': '',
	        			  'vcard:street-address': '',
	        			  'vcard:post-office-box': '',
	        			  'vcard:postal-code': '',
	        			  'vcard:locality': '',
	        			  'vcard:country-name': '',
	        			  'owltime:hasBeginning': null,
	        			  'owltime:hasEnd': ''}
	        			},
	        'newAccount': {'method': 'POST', 'path': 'person/', 'template':{
	        			  'dc:title': null,
	        			  'foaf:accountName': null,
	        			  'foaf:accountServiceHomepage': ''}
	        			},
	        'editAccount': {'method': 'PUT', 'path': 'person/', 'template':{
	        			  'dc:title': null,
	        			  'foaf:accountName': null,
	        			  'foaf:accountServiceHomepage': ''}
	        			},
	        'editAffiliation': {'method': 'PUT', 'path': 'person/', 'template':{
	        			  'org:organization': null,
	        			  'vcard:email': '',
	        			  'vcard:title': '',
	        			  'vcard:street-address': '',
	        			  'vcard:post-office-box': '',
	        			  'vcard:postal-code': '',
	        			  'vcard:locality': '',
	        			  'vcard:country-name': '',
	        			  'owltime:hasBeginning': null,
	        			  'owltime:hasEnd': ''}
	        			},
	     	'editPerson': {'method': 'PUT', 'path': 'person/', 'template': {
	                      "foaf:name": null,
	                      "foaf:givenName": null,
	                      "foaf:familyName": null,
	                      "foaf:title": "",
	                      "foaf:image": "",
	                      "foaf:homepage": "",
	                      "foaf:mbox": null,
	                      "org:reportsTo": null}
	                    },
	        'editWork':  {'method': 'PUT', 'path': 'work/', 'template': {
	        			  'dc:title': null,
	        			  'bibo:authorList': null,
	        			  'dc:abstract': null,
	        			  'bibo:doi': '',
	        			  'dc:date': '',
	        			  'bibo:uri': [],
	        			  'bibo:volume': '',
	        			  'bibo:pages': '',
	        			  'bibo:pageStart': '',
	        			  'bibo:pageEnd': '',
	        			  'dc:publisher': '',
	        			  'dc:subject': [],
	        			  'dc:bibliographicCitation': '',
	        			  'dc:creator': null}
	        			},	                    
	        'editLicense': {'method': 'PUT', 'path': 'work/', 'template':{
	        			  'dc:title': null,
	        			  'dc:description': null,
	        			  'ali:start_date': null,
	        			  'ali:end_date': '',
	        			  'ali:uri': ''}
	        			},  
	        'deleteAccount': {'method': 'DELETE', 'path': 'person/', 'template':{ }
	        			},    			
	        'deleteAffiliation': {'method': 'DELETE', 'path': 'person/', 'template':{ }
	        			},
	        'deleteLicense': {'method': 'DELETE', 'path': 'work/', 'template':{ }
	        			},
	        'deleteWork': {'method': 'DELETE', 'path': 'work/', 'template':{ }
	        			}	        			

	    };
	};

  	Plugin.prototype = {
    	'init': function(opt){
	        $.extend(this.options, opt);
	    },

	    'extendForms': function(){
	    	var handle = this;
	        var forms = $('form').filter(function(){return typeof $(this).data('lna-query') !== 'undefined'});
	        forms.each(function(){ handle.extendForm(this) });
	    },

	    //tk decide if I'm going to use these
	    'clearErrors': function(){
	      this.errors = [];
	    },

	    'getErrors': function(){
	      return this.errors;
	    },

	    //Queries associated with forms are mostly handled using extendForm below.
	    //Reading and button presses are handled with convenience functions
	    'listOrgs': function(callback, page){
	    	if(typeof page === "undefined") page = 1;
	    	this.submitQuery('listOrgs', {}, callback, page);
	    },

	    'listPersons': function(callback, page){
	    	if(typeof page === "undefined") page = 1;
	    	this.submitQuery('listPersons', {}, callback, page);
	    },

	    'listWorks': function(callback, page){
	    	if(typeof page === "undefined") page = 1;
	    	this.submitQuery('listWorks', {}, callback, page);
	    },	    

	    'loadPerson': function(callback, uid){
	    	if(typeof uid === "undefined") return false;
	    	this.submitQuery('loadPerson', {}, callback, uid);
	    },
	    'loadOrg': function(callback, uid){
	    	if(typeof uid === "undefined") return false;
	    	this.submitQuery('loadOrg', {}, callback, uid);
	    },	
	    'loadWork': function(callback, uid){
	    	if(typeof uid === "undefined") return false;
	    	this.submitQuery('loadWork', {}, callback, uid);
	    },		    
	    'loadPersonWorks': function(callback, uid){
	    	if(typeof uid === "undefined") return false;
	    	this.submitQuery('loadPerson', {}, callback, uid + '/works');
	    },

	    //Search queries
	    'findOrgs': function(callback, term, page){
	    	if(typeof term === "undefined") return false;
	    	if(typeof page === "undefined") page = 1;
	    	var searchTerm = {'skos:prefLabel': term}
	    	this.submitQuery('findOrgs', searchTerm, callback, page);
	    },
	    'findOrgPersons': function(callback, uid, page){
	    	if(typeof uid === "undefined") return false;
	    	if(typeof page === "undefined") page = 1;
	    	var searchTerm = {'org:member': uid};
	    	this.submitQuery('findOrgPersons', searchTerm, callback, page);
	    }, 
	    'findPersons': function(callback, term, page){
	    	if(typeof term === "undefined") return false;
	    	if(typeof page === "undefined") page = 1;
	    	var searchTerm = {'foaf:name': term};
	    	this.submitQuery('findPersons', searchTerm, callback, page);
	    	return false;
	    },

	    //extendForm is called on all forms that have data-lna-query set on init
	    //it can also be run manually.
	    'extendForm': function(formElement){
    		var handle = this;
			var $formElement = $(formElement);

			//Validation
		    var query = $formElement.data('lna-query');
		    if(typeof query ==="undefined"){
		    	console.log('Tried to extend a form without an lna-query set');
		        return false;
		    }
		    if(typeof this.queries[query] === 'undefined'){
		        console.log('Tried to extend a form for which there is no query: '+query);
		        return false;
		    }
      

      		$formElement.submit(function(e){
	        	e.preventDefault();

	        	var formData = handle.readForm(this);

	        	if(!formData) {
	        		console.log(handle.getErrors());    //tk do something useful with errors
	        		return false;
	       		}

	       		var opt = '';
	       		if(typeof $formElement.data('opt') != "undefined") opt = $formElement.data('opt');

	       		var ajax=true;
	       		if(typeof $formElement.data('no-ajax') != "undefined") ajax = false;

	       		var fn=null;
	       		if(typeof $formElement.data('refresh') != "undefined") fn = function(){location.reload()};
	       		if(typeof $formElement.data('handler') != "undefined") fn = LNA[$formElement.data('handler')];

	        	handle.submitQuery(query, formData, fn, opt, ajax);

	        	return false;
			});

			$formElement.attr('data-ready', 'true');
    	},

    	'readForm': function(formElement){
      		var handle = this;
    		var $formElement = $(formElement);

    		//Validation
    		var query = $formElement.data('lna-query');
    		if(typeof query === 'undefined'){
       			console.log('Form element needs a data-lna-query value.');
        		return false;
      		}
      		if(typeof this.queries[query] === 'undefined'){
        		console.log('Tried to read a form for which there is no query');
        		return false;
      		}

      		//merge form data into a copy of the template
      		var data = $.extend(true, {}, this.queries[query].template);
		    var formData = $formElement.serializeArray();
		    $.each(formData, function(k,v){
        		if(typeof data[v.name] !== 'undefined' && v.value != '') data[v.name]=v.value;
        		if(v.name == 'authenticity_token' && handle.options.authenticity_token) data[v.name] = v.value;
      		});

      		//If the form has fields with tag behavior, split those fields into an array.
      		var delimiter = false;
      		if(typeof $formElement.data('tag-delimiter') !== "undefined") delimiter = $formElement.data('tag-delimiter');
      		if(delimiter){
      			$formElement.find('input').each(function(i, v){
      				if($(v).hasClass('tagBehavior') && typeof data[v.name] === "string") data[v.name] = data[v.name].split(delimiter);
      			});
      		} 		

      		//validate and errors
      		var fail = false;
      		$.each(data, function(k,v){
        		if(data[k]===null){
          			console.log("Form missing required field: "+k);
          			handle.errors.push("Missing required field, submission stopped.");
          			fail = true;
        		}
      		});

      		if(fail) return false;

      		return data;
    	},

    	'submitQuery': function(query, formData, fn, opt, ajax){
    		if(typeof fn == "undefined" || fn == null) fn = function(){ return false };
    		if(typeof opt == "undefined") opt = '';
    		if(typeof ajax == "undefined") ajax = true;
	     	var queryData = this.queries[query];
    	 	if(ajax){
	    	 		$.ajax({
		    	    "url": this.options.baseURL + queryData.path + opt,
		        	"method": queryData.method,
			        "accepts": {"json": "application/ld+json"},
			        "data": formData,
			        "dataType": "json",
			        "success": fn
	      		});
	    	} else {
	      		$.form(this.options.baseURL + queryData.path + opt, formData, queryData.method).submit();
	      	}
    	},

    	//Reads linked data graphs and turns them into more useful arrays
    	'readLD': {
    		'persons': function(xhrData){
	    		var data = {'persons': [], 'orgs': []};
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='org:Organization') data.orgs.push(v);
	    		});
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='foaf:Person'){
	    				var org = $.grep(data.orgs, function(o){ return v['org:reportsTo'] == o['@id']});
	    				if(org.length > 0) v.orgLabel = org[0]['skos:prefLabel'];
	    				else v.orgLabel = '';
	    				data.persons.push(v);
	    			}
	    		});
	    		return data;
	    	},
    		'person': function(xhrData){
	    		var data = {'person': [], 'accounts': [], 'memberships': [], 'orgs': []};

	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='foaf:Person') data.person = v;
					if(v['@type']=='foaf:OnlineAccount') data.accounts.push(v);
					if(v['@type']=='org:Organization') data.orgs.push(v);
	    		});
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='org:Membership'){
		    			var org = $.grep(data.orgs, function(o){ return v['org:organization'] == o['@id']});
		    			if(org.length > 0) v.orgLabel = org[0]['skos:prefLabel'];
		    			else v.orgLabel = '';
		    			data.memberships.push(v);
		    		}
		    		if(v['@type']=='foaf:Person'){
		    			var org = $.grep(data.orgs, function(o){ return v['org:reportsTo'] == o['@id']});
		    			if(org.length > 0) v.orgLabel = org[0]['skos:prefLabel'];
		    			else v.orgLabel = '';		    			
		    		}
	    		});

	    		return data;
	    	},
	    	'org': function(xhrData){
	    		var data = {'org': {}, 'accounts': [], 'parent': {}, 'children': []};
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='org:Organization') {
	    				if(xhrData['foaf:primaryTopic'] == v['@id']) data.org = v;
	    			}
	    			if(v['@type']=='foaf:OnlineAccount') data.accounts.push(v)
	    		});
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='org:Organization') {
	    				if(data.org['org:subOrganizationOf'] == v['@id']) data.parent = v;
	    				else if(xhrData['foaf:primaryTopic'] != v['@id']) data.children.push(v);
	    			}
	    			if(v['@type']=='foaf:OnlineAccount') data.accounts.push(v)
	    		});	    		
	    		return data;
	    	},
	    	'work': function(xhrData){
	    		var data = {'person': [], 'work': [], 'licenses': []};

	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='foaf:Person') data.person = v;
					if(v['@type']=='bibo:Document') data.work = v;
					if(v['@type']=='dc:licenseDocument') data.licenses.push(v);
	    		});
	    		$.each(data.licenses, function(i, v){
	    			var free = $.grep(data.work['ali:free_to_read'], function(f){ return v['@id'] == f});
	    			if(free.length > 0) v['dc:description'] = "ali:free_to_read";
	    			else v['dc:description'] = "ali:license_ref";
	    		});

	    		return data;
	    	},
    		'personWorks': function(xhrData){
	    		return xhrData['@graph'];
	    	},
    		'works': function(xhrData){
	    		return xhrData['@graph'];
	    	},	    	
	    	'orgs': function(xhrData){
	    		return xhrData['@graph'];
	    	}

    	},

    	//Utility function to parse link headers
    	'parseLink': function(linkText){
			if (linkText.length == 0) {
				return {};
			}

			// Split parts by comma
			var parts = linkText.split(',');
			var links = {};
	
			// Parse each part into a named link
			$.each(parts, function(i, p) {
				var section = p.split(';');
				if (section.length != 2) {
					console.log("section could not be split on ';'");
				}
				var url = section[0].replace(/<(.*)>/, '$1').trim();
				var name = section[1].replace(/rel="(.*)"/, '$1').trim();
				links[name] = url;
			});

			links.total = 1;
			links.current = 1;
			if(links.last) links.total = parseInt(links.last.split('/').pop());
			if(links.next) links.current = parseInt(links.next.split('/').pop()) - 1;
			if(links.prev) links.current = parseInt(links.prev.split('/').pop()) + 1;

			return links;
    	}
	};

	/*
	 * Plugin wrapper, preventing against multiple instantiations and
     * return plugin instance.
     */
	$.fn[pluginName] = function(opt) {

    	var plugin = this.data(dataKey);

    	// has plugin instantiated ?
    	if (plugin instanceof Plugin) {
        	// if we have options arguments, call plugin.init() again
        	if (typeof opt !== 'undefined') {
            	plugin.init(opt);
        	}
    	} else {
        	plugin = new Plugin(this, opt);
        	this.data(dataKey, plugin);
    	}

      	return plugin;
  	};

  	$('document').ready(function(){
    	var lna = $(document).LNAGateway();
    	lna.init();
  	});
}(jQuery, window, document));
