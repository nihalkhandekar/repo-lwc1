import LightningDatatable from 'lightning/datatable';
import actions from './actions.html';
import { api } from 'lwc';


export default class CustomDataTableTypes extends LightningDatatable {

    static customTypes = {  
        actions :{
            template : actions,
            typeAttributes : ['recordId','customerId']
        },
        
    };

}