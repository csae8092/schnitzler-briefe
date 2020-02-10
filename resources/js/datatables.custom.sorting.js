jQuery.fn.dataTable.ext.type.order['handle-question-marks-pre'] = function ( data ) {
    let position = data.lastIndexOf('<surname>') + 9;
    let surnameWithoutStartTag = data.substring(position,data.length);
    position = surnameWithoutStartTag.lastIndexOf('</surname>');
    let surname = surnameWithoutStartTag.substring(0,position);
    if (surname === "??" || surname === ''){
        return 'ỿỿỿỿ'
    }
    else { return surname }
}