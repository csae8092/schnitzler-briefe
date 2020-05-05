/*https://www.sitepoint.com/url-parameters-jquery/*/
$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}

/*http://stackoverflow.com/questions/5448545/how-to-retrieve-get-parameters-from-javascript*/
function findGetParameter(parameterName) {
    var result = null,
        tmp = [];
    var items = location.search.substr(1).split("&");
    for (var index = 0; index < items.length; index++) {
        tmp = items[index].split("=");
        if (tmp[0] === parameterName) result = decodeURIComponent(tmp[1]);
    }
    return result;
}

/*script for loading the content of the modal */
$(document).ready(function(){
   var trigger = $('a[data-key],a[data-keys]');
   $(trigger).click(function(){
   var dataType = $( this ).attr('data-type');
   var dataKey = $( this ).attr('data-key');
   var dataKeys = $( this ).attr('data-keys');
   // if (dataKeys != undefined && dataKeys != "" && dataKeys != null){
   if(dataKeys != undefined){
      let html = "<div id='linksModal' tabindex='-1' class='modal' role='dialog' aria-labelledby='modal-label'>";
      html = html + "<div class='modal-dialog modal-sm' role='document'>";
      html = html + "<div class='modal-content'>";
      html = html + "<div class='modal-header'>";
      html = html + "<h3 class='modal-title' id='modal-label'>Links</h3></div>";
      html = html + "<div class='modal-body'>";
      let keys = dataKeys.split(' ');
      if(dataType != undefined){
          for (let j = 0; j < keys.length; j++){
              keys[j] = keys[j].substring(1,keys[j].length); // Remove hash
          }
      }
      let linkTitles = [];
      let promises = [];
      for (let i = 0; i < keys.length; i++){
          let dataTypeInKey = '';
          let key = '';
          if(dataType != undefined){
              dataTypeInKey = dataType;
              key = keys[i];
          }
          else {
            if (keys[i].startsWith('work')){ dataTypeInKey = 'listwork.xml'; key = keys[i].substring(5,keys[i].length); }
            else if (keys[i].startsWith('org')){ dataTypeInKey = 'listorg.xml'; key = keys[i].substring(4,keys[i].length); }
            else if (keys[i].startsWith('person')){ dataTypeInKey = 'listperson.xml'; key = keys[i].substring(7,keys[i].length); }
            else if (keys[i].startsWith('place')){ dataTypeInKey = 'listplace.xml'; key = keys[i].substring(6,keys[i].length); }
          }
          let linkTitle = '';
          let url = "showNoTemplate.html?directory=indices&document=" + dataTypeInKey + "&entiyID=" + key;
          promises[i] = $.get(url,function(data){
                let parser = new DOMParser();
                let contentAsDOM = parser.parseFromString(data, "text/html");
                linkTitle = contentAsDOM
                    .getElementsByTagName('div')[0]
                    .getElementsByTagName('div')[0]
                    .getElementsByTagName('div')[0]
                    .getElementsByTagName('div')[1]
                    .getElementsByTagName('table')[0]
                    .getElementsByTagName('tr')[0]
                    .getElementsByTagName('td')[0].childNodes[0].nodeValue;
                linkTitles.push(linkTitle);
          });
          promises[i].always(function(){
            let anchor = "<div><a data-type='" + dataTypeInKey + "' data-key='" + key + "'>" + linkTitle + "</a></div>";
            html = html + anchor;
          });
      }
      Promise.all(promises).then(function(){
        html = html + "</div><div class='modal-footer'><button onclick='$(`#linksModal`).modal(`hide`);$(`#linksModal`).remove();' type='button' class='btn btn-secondary' data-dismiss='modal'>X</button></div>" + "</div></div></div>";
        $('#linksModal').remove();
        $('#loadModal').append(html);
        $('#linksModal').modal('show');
        $('#linksModal').focus();
              
        let handlesForModalLinks = $('#linksModal div div a');
        console.log(handlesForModalLinks);
        $(handlesForModalLinks).each(function(){$(this).click(function(){
            let dataType = $( this ).attr('data-type');
            let dataKey = $( this ).attr('data-key');
            let baseUrl = "showNoTemplate.html?directory=indices&document=";
            let url = baseUrl + dataType + "&entiyID=" + dataKey;
            $('#loadModal').load(url, function(){
                $('.modal-backdrop').remove();
                $('#linksModal').remove();
                $('#myModal').modal('show');
            });
        });
        });
      });
   }
   else{
       var xsl = dataType.replace(".xml", "");
       var baseUrl = "showNoTemplate.html?directory=indices&document="
       var url = baseUrl+dataType+"&entiyID="+dataKey;
       $('#loadModal').load(url, function(){
		   
		// new code start
	  let mentionedLink = $('#myModal div div div h3 small a');
	  if (mentionedLink !== undefined){
		let reference = $(mentionedLink).attr('href');
		let pmbKey = 0;
		if (reference !== undefined){
			// console.log(reference);
			let position = reference.lastIndexOf('pmb');
			pmbKey = reference.substring(position + 3,reference.length);
		}
		else{
			mentionedLink = $('#myModal div div div h4 a'); // this case should not be necessary because the delivered html for the modal was corrected
			if (mentionedLink !== undefined){
				let reference = $(mentionedLink).attr('href');
				if (reference !== undefined){
					let position = reference.lastIndexOf('pmb');
					pmbKey = reference.substring(position + 3,reference.length);
				}
			}
		}
		// console.log(pmbKey);
		let url = 'https://pmb.acdh.oeaw.ac.at/apis/api2/entity/' + pmbKey + '/?format=json';
		let promise = $.get(url,function(data){
			// console.log(data);
			if (data.entity_type === 'Work'){
				for (let i = 0; i < data.relations.persons.length; i++){
					let urlOfPerson = data.relations.persons[i].target.url;
					if (urlOfPerson !== undefined && data.relations.persons[i].relation_type.label.startsWith('steht in Beziehung zu Person >> geschaffen von')){
						let secondPromise = $.get(urlOfPerson,function(data){
							// console.log(data);
						});
						secondPromise.then(function(data){
							let surname = data.name;
							let firstName = data.first_name;
							let birth = data.start_date;
							let death = data.end_date;
							let idOfPerson = data.id;
							let linkhref = '/pages/hits.html?searchkey=pmb' + idOfPerson;
							$('.modal-body').append('<div><a href="' + linkhref + '">' + firstName + ' ' + surname + '</a></div>');
							$('.modal-body').append('<div>' + birth + " - " + death + '</div>');
						});
					}
					else{
						let idOfRelation = data.relations.persons[i].target.id;
						let labelOfRelation = data.relations.persons[i].relation_type.label;
						let targetOfRelation = data.relations.persons[i].target.name;
						let firstname = data.relations.persons[i].target.first_name;
						let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
						$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + firstname + " " + targetOfRelation + '</a></div>');
					}
				}
				// persons relations
				for (let i = 0; i < data.relations.persons.length; i++){
					let idOfRelation = data.relations.persons[i].target.id;
					let labelOfRelation = data.relations.persons[i].relation_type.label;
					let targetOfRelation = data.relations.persons[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// places relations
				for (let i = 0; i < data.relations.places.length; i++){
					let idOfRelation = data.relations.places[i].target.id;
					let labelOfRelation = data.relations.places[i].relation_type.label;
					let targetOfRelation = data.relations.places[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// events relations
				for (let i = 0; i < data.relations.events.length; i++){
					let idOfRelation = data.relations.events[i].target.id;
					let labelOfRelation = data.relations.events[i].relation_type.label;
					let targetOfRelation = data.relations.events[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// works relations
				for (let i = 0; i < data.relations.works.length; i++){
					let idOfRelation = data.relations.works[i].target.id;
					let labelOfRelation = data.relations.works[i].relation_type.label;
					let targetOfRelation = data.relations.works[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// institutions relations
				for (let i = 0; i < data.relations.institutions.length; i++){
					let idOfRelation = data.relations.institutions[i].target.id;
					let labelOfRelation = data.relations.institutions[i].relation_type.label;
					let targetOfRelation = data.relations.institutions[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
			}
			if (data.entity_type === 'Institution' || data.entity_type === 'Places' || data.entity_type === 'Persons' || data.entity_type === 'Events'){
				// places relations
				for (let i = 0; i < data.relations.places.length; i++){
					let idOfRelation = data.relations.places[i].target.id;
					let labelOfRelation = data.relations.places[i].relation_type.label;
					let targetOfRelation = data.relations.places[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// events relations
				for (let i = 0; i < data.relations.events.length; i++){
					let idOfRelation = data.relations.events[i].target.id;
					let labelOfRelation = data.relations.events[i].relation_type.label;
					let targetOfRelation = data.relations.events[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// works relations
				for (let i = 0; i < data.relations.works.length; i++){
					let idOfRelation = data.relations.works[i].target.id;
					let labelOfRelation = data.relations.works[i].relation_type.label;
					let targetOfRelation = data.relations.works[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// institutions relations
				for (let i = 0; i < data.relations.institutions.length; i++){
					let idOfRelation = data.relations.institutions[i].target.id;
					let labelOfRelation = data.relations.institutions[i].relation_type.label;
					let targetOfRelation = data.relations.institutions[i].target.name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// persons relations
				for (let i = 0; i < data.relations.persons.length; i++){
					let idOfRelation = data.relations.persons[i].target.id;
					let labelOfRelation = data.relations.persons[i].relation_type.label;
					let targetOfRelation = data.relations.persons[i].target.name;
					let firstname = data.relations.persons[i].target.first_name;
					let linkhref = '/pages/hits.html?searchkey=pmb' + idOfRelation;
					$('.modal-body').append('<div>' + labelOfRelation + ' <a href="' + linkhref + '">' + firstname + " " + targetOfRelation + '</a></div>');
				}
			}
		});
	  }
	  // new code end   
		   
       $('#myModal').modal('show');
       });
   }   
   });
});