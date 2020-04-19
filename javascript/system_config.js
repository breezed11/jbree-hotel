function load_system_config() {
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
            type: "system_config"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("action_pane").innerHTML = result;
            document.getElementById("title").innerHTML = "System Config";
            load_system_config_results();

        }
    });
}

function load_system_config_results() {
    var url_to_send = 'cgi-bin/hotel.pl';
    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        },
        "SearchFields": {
            "display_name": document.getElementById("name_searchfield").value,
            "value": document.getElementById("value_searchfield").value,
        }
    };
    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "system_config_results"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("system_config_results").innerHTML = result;
        }
    });
}