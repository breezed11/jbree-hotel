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
    window.alert(data);
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

    send_request(url_to_send, data_to_send, 'login');
}