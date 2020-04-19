function load_users() {
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
            type: "users"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("action_pane").innerHTML = result;
            document.getElementById("title").innerHTML = "Users";
            load_users_results();

        }
    });
}

function load_users_results() {
    var url_to_send = 'cgi-bin/hotel.pl';
    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        },
        "SearchFields": {
            "username": document.getElementById("username_searchfield").value,
            "forename": document.getElementById("forename_searchfield").value,
            "surname": document.getElementById("surname_searchfield").value,
        }
    };
    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "users_results"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("users_results").innerHTML = result;
        }
    });
}
function reset_password_form() {
    document.getElementById("new_or_edit_content_old").innerHTML = document.getElementById("new_or_edit_content").innerHTML;

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
            type: "password_reset"
        },
        success: function (result) {
            check_for_errors(result);
            document.getElementById("new_or_edit_content").innerHTML = result;
            document.getElementById("new_username_neweditfield").value = document.getElementById("username_neweditfield").value;
            document.getElementById("user_id_neweditfield").value = document.getElementById("id_neweditfield").value;
        }
    });
}

function reset_password() {
    var url_to_send = 'cgi-bin/hotel.pl';

    var new_pw = document.getElementById("new_pw_neweditfield").value;
    var new_confirm = document.getElementById("confirm_pw_neweditfield").value;

    if (new_pw !== new_confirm) {
        window.alert("Passwords do not match.");
        return 1;
    }

    var data_to_send = {
        "Authentication": {
            "cookie": document.getElementById("cookie").value,
            "csrf_token": document.getElementById("csrf_token").value
        },
        "NewEditFields": {
            "id": document.getElementById("user_id_neweditfield").value,
            "pw": document.getElementById("new_pw_neweditfield").value
        }
    };
    data_to_send = JSON.stringify(data_to_send);
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref: document.getElementById("system_ref").value,
            type: "updateinsert_user"
        },
        success: function (result) {
            check_for_errors(result);
            window.alert("Password Changed");
            document.getElementById("new_or_edit_content").innerHTML = document.getElementById("new_or_edit_content_old").innerHTML;
            document.getElementById("new_or_edit_content_old").innerHTML = "";
        }
    });
}