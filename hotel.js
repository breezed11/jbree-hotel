function send_request(url_to_send, data_to_send) {
    data_to_send = '{"test": "test"}';
    $.ajax(url_to_send, {
        type: 'POST',
        data: {
            request: data_to_send,
            system_ref : document.getElementById("system_ref").value
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