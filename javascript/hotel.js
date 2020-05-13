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

function logout() {
    location.reload();
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

function close_newedit() {
    $('new_or_edit_content').empty();
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

function delete_record() {
    var url_to_send = 'cgi-bin/hotel.pl';

    var input = document.getElementsByName("id")[0].value;

    var data_to_send = '{"Authentication":{"cookie":"';
    data_to_send += document.getElementById("cookie").value;
    data_to_send += '","csrf_token":"'
    data_to_send += document.getElementById("csrf_token").value;
    data_to_send += '"},"DeleteRecord":';
    data_to_send += '{"id":"' + input;
    data_to_send += '"}}';

    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: document.getElementById("save_name").value
        },
        success: function (result) {
            window.alert("Deleted");
            close_newedit();
        }
    });
}

function new_or_update(type_ref, id) {
    var url_to_send = 'cgi-bin/hotel.pl';

    if (!id) {
        id = "0";
    }

    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        },
        "SearchFields": {
            "id": id
        }
    };

    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: type_ref
        },
        success: function (result) {
            check_for_errors(result);
            var new_or_edit = document.getElementById("new_or_edit");
            new_or_edit.style.display = "block";
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

function revert_old_newedit() {
    document.getElementById("new_or_edit_content").innerHTML = document.getElementById("new_or_edit_content_old").innerHTML;
    document.getElementById("new_or_edit_content_old").innerHTML = "";
}