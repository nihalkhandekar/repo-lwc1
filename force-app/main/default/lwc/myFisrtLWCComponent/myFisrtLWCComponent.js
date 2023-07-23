import { LightningElement, track, wire } from 'lwc';
import {fireEvent} from 'c/pubsub'; //to register thr component//
import {CurrentPageReference} from 'lightning/navigation'; //to get the current page URL
import getContactData from '@salesforce/apex/getApexData.getContactData';

export default class MyFisrtLWCComponent extends LightningElement {

    @track
    welcomeNote = 'Hello Guyz !!';
    @track
    updateColor = false;
    Students = ['Nihal', 'Neha', 'Naina', 'Pinky', 'Nayan'];

    handleChange(event){
        let inputValue = event.target.value;
        console.log(inputValue);
        console.log(event.target.label);
        if(event.target.label === 'Enter Welcome Note30' ){
            this.welcomeNote = inputValue;
        }
        if(!this.welcomeNote || this.welcomeNote === ''){
            this.updateColor = false;
        }
        else{
            this.updateColor = true;
        }
        if(event.target.label === 'Enter Welcome Note4' ){ //for publisher & subscriber//
            fireEvent(this.pageRef, 'pubsubhit', inputValue); //yha 3 parametrs pass krne hai 1. URL jha hit krna hai(registered), 2. event name,3. paremetr jo bhejna hai//
      //ab jaise hi input me value change hogi event fire hoga//
      //fire hone k baad vo URL me jakr dekhega ki ye 'pubsubhit' kha pr register hai//
      //usk baad vha konsa method hai vo fire hoga(which is in child component)//
        }
    }

    @wire(CurrentPageReference) //You can @wire a property or a function to receive the data.//
    pageRef;

    @track viewData = [];
    searchkey = '';
    //new//
    @wire(getContactData, {name:'$searchkey'})
    showContacts({data,error}){
        if(data){
            console.log('Data is present', data);
            this.viewData=data;
        }
        else if(error){
            console.log('Errors', error);
        
        }
        //return this.wirestoredrecords?.data?.fields?.Name?.value;//
    }
    handleSearch(event){
        this.searchkey = event.target.value; 
    }
    Teachers = 
       [ {
           Name : 'Ajay Sir', Subject: 'English', Class: 9, 
           Qualification:{
            Graduation: 'BE',
            Masters: 'ME',
           } 
        },
        {
            Name : 'Vijay Sir', Subject: 'Maths', Class: 8, 
            Qualification:{
             Graduation: 'BA',
             Masters: 'MA',
            } 
         }
        ] 


    handleChangeCheckbox(event){
        console.log(event.target.label);
        console.log(event.target.checked);
    }

//learning new//
    result = false;
    connectedCallback(){
       setTimeout(()=>{
        this.result = true;
       },4000)
    }

    handleChange(event){
        this.result = event.target.checked;
    }

    name;
    email;
    password;

    handleChange2(event){
        let input = event.target.label;
        if(input=='Name'){
            this.name = event.target.value;
        }
        if(input=='Email'){
            this.email = event.target.value;
        }
        if(input=='Password'){
            this.password = event.target.value;
        }
    }
    showResult = false;
    handleClick(){
        this.showResult = true;
    }
}