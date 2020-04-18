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
    return 1;
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

    let data_to_send = {
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
            if(check_for_errors(json_response, "login")) {
                document.getElementById("action_pane").innerHTML = "";
                document.getElementById("cookie").value = json_response.cookie;
                document.getElementById("csrf_token").value = json_response.csrf_token;
                $.ajax(url_to_send, {
                    type: 'POST',
                    data: {
                        request: data_to_send,
                        system_ref: document.getElementById("system_ref").value,
                        type: "left_menu"
                    },
                    success: function (result) {
                        document.getElementById("left_menu").innerHTML += result;
                    }
                });
            }
        }
    });

}