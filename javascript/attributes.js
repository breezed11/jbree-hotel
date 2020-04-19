function load_attributes() {
    var url_to_send = 'cgi-bin/hotel.pl';
    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        }
    };

    data_to_send = JSON.stringify(data_to_send);

    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "attributes"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("action_pane").innerHTML = result;
            document.getElementById("title").innerHTML = "Attributes";
            load_attributes_results();

        }
    });
}

function load_attributes_results() {
    var url_to_send = 'cgi-bin/hotel.pl';
    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        },
        "SearchFields": {
            "name": document.getElementById("name_searchfield").value,
            "description": document.getElementById("description_searchfield").value,
        }
    };
    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "attributes_results"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("attributes_results").innerHTML = result;
        }
    });
}