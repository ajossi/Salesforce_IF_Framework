import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * 
 * @param {*} cmp 
 * @param {*} variant success, error, warning, info
 * @param {*} title title
 * @param {*} message message
 */
export function showToast(cmp, variant, title, message){
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    })

    cmp.dispatchEvent(event);
}

/**
 * data empty check
 * @param {*} data 
 * @returns 
 */
export function isEmpty(data){
    // console.log('test01-> ' + isEmpty(null)); // true
    // console.log('test02-> ' + isEmpty('')); // true
    // console.log('test03-> ' + isEmpty('  ')); // true
    // console.log('test04-> ' + isEmpty(undefined)); // true
    // console.log('test05-> ' + isEmpty({})); // true
    // console.log('test06-> ' + isEmpty({arr:[], test:{}})); // false
    // console.log('test07-> ' + isEmpty([])); // true
    // console.log('test08-> ' + isEmpty(['te'])); // false
    // console.log('test09-> ' + isEmpty(0)); // false
    // console.log('test10-> ' + isEmpty('Hey')); // false
    if(typeof(data) === 'object'){
        if(JSON.stringify(data) === '{}' || JSON.stringify(data) === '[]'){
            return true;
        }else if(!data){
            return true;
        }
        return false;
    }else if(typeof(data) === 'string'){
        if(!data.trim()){
            return true;
        }
        return false;
    }else if(typeof(data) === 'undefined'){
        return true;
    }else{
        return false;
    }
}