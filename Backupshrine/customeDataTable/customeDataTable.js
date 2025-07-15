import LightningDatatable from 'lightning/datatable';
import actions from './actions.html';
import { LightningElement } from 'lwc';

export default class CustomeDataTable extends LightningDatatable {

    static customTypes = {  
        actions :{
            template : actions,
            typeAttributes : ['recordId']
        },
        
    };
}