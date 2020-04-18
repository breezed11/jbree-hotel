function send_request(url_to_send, data_to_send, type_to_send) {
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: type_to_send
        },
        success: function (result) {
            check_for_errors(result);
            return result;
        }
    });
}


function check_for_errors(data) {
    try {
        data = JSON.parse(data);
        if (data.error) {
            window.alert(data.error_message);
            location.reload();
        }
    } catch (err) {
        //do nothing, it means a template was sent
    }
}

function login() {
    var url_to_send = 'cgi-bin/hotel.pl';
    var username = document.getElementById("uname").value;
    var password = document.getElementById("psw").value;

    if (!username) {
        window.alert("Please enter a username.");
        return 1;
    }

    if (!password) {
        window.alert("Please enter a password.");
        return 1;
    }

    var data_to_send = {
        "Authentication": {
            "username": username,
            "password": password
        }
    };

    data_to_send = JSON.stringify(data_to_send);

    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "login"
        },
        success: function (result) {
            var json_response = JSON.parse(result);
            check_for_errors(result, "login")
            document.getElementById("title").innerHTML = "Dashboard";
            document.getElementById("action_pane").innerHTML = "";
            document.getElementById("cookie").value = json_response.cookie;
            document.getElementById("csrf_token").value = json_response.csrf_token;
            $.ajax(url_to_send, {
                type: 'POST',
                data: {
                    request: JSON.stringify({
                        "Authentication": {
                            "cookie": document.getElementById("cookie").value,
                            "csrf_token": document.getElementById("csrf_token").value
                        }
                    }),
                    system_ref: document.getElementById("system_ref").value,
                    type: "left_menu"
                },
                success: function (result) {
                    document.getElementById("left_menu").innerHTML += result;
                }
            });

        }
    });

}

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
            load_system_config_results(url_to_send);

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

function new_system_config_option(id) {
    var url_to_send = 'cgi-bin/hotel.pl';
    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        }
    };

    if (id) {
        data_to_send = {
            "Authentication": {
                "cookie": document.getElementById("cookie").value,
                "csrf_token": document.getElementById("csrf_token").value
            },
            "SearchFields": {
                "id": id
            }
        };
    }

    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "system_config_new"
        },
        success: function (result) {
            check_for_errors(result);
            var new_or_edit = document.getElementById("new_or_edit");
            var span = document.getElementsByClassName("close_new_or_edit")[0];
            new_or_edit.style.display = "block";
            span.onclick = function () {
                new_or_edit.style.display = "none";
            }
            window.onclick = function (event) {
                if (event.target == new_or_edit) {
                    new_or_edit.style.display = "none";
                }
            }
            var elem = document.getElementById("new_or_edit_content");
            elem.innerHTML = result;
        }
    });
}

function close_newedit() {
    document.getElementById("new_or_edit").style.display = "none";
}

function save() {
    var url_to_send = 'cgi-bin/hotel.pl';

    var inputs = document.getElementsByClassName("ToSave");

    var fields = '{';

    for (item of inputs) {
        fields += '"';
        fields += item.name;
        fields += '":"';
        fields += item.value;
        fields += '",';
    }

    fields += '"":""}';

    var data_to_send = '{"Authentication":{"cookie":"';
    data_to_send += document.getElementById("cookie").value;
    data_to_send += '","csrf_token":"'
    data_to_send += document.getElementById("csrf_token").value;
    data_to_send += '"},"NewEditFields":';
    data_to_send += fields;
    data_to_send += '}';

    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: document.getElementById("save_name").value
        },
        success: function (result) {
            var inputs = document.getElementsByClassName("ToSave");
            for (item of inputs) {
                if (item.name == "id") {
                    item.value = result;
                }
            }
            window.alert("Saved");
        }
    });
}