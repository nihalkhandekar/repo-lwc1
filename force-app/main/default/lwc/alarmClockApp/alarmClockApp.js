import { LightningElement } from 'lwc';
import alarmClockAsset from '@salesforce/resourceUrl/AlarmClockAssets';

export default class AlarmClockApp extends LightningElement {
    clockImage = alarmClockAsset + '/AlarmClockAssets/clock.png' 
    ringtone = new Audio (alarmClockAsset + '/AlarmClockAssets/Clocksound.mp3') //Audio - Audio constructor
    currentTime = ''
    hour = []    //empty array
    minute = []
    meridiems = ['AM', 'PM']
    alarmTime
    isAlarmSet = false
    isAlarmTriggered = false
    
    hourSelected 
    minuteSelected 
    meridiemSelected


    get isFieldNotSelected(){
        const isNotSelected = !(this.hourSelected && this.minuteSelected && this.meridiemSelected);
        return isNotSelected;    
    }

    get shakeImage(){
        return this.isAlarmTriggered ? 'shake' : ''
    }

    connectedCallback(){    
        this.currentTimeHandler()
        this.createHoursOption()
        this.createMinutesOption()
    }

    currentTimeHandler(){

        setInterval(()=>{
            let DateTime = new Date()
            let hours = DateTime.getHours()
            let mins = DateTime.getMinutes()
            let secs = DateTime.getSeconds()
            let ampm = "AM"
            
            if(hours === 0){
                hours = 12 
            }
            else if (hours === 12) {
                ampm = "PM"
            }
            else if(hours > 12){
                hours = hours-12
                ampm = "PM"
            }
    
            hours = hours <10 ? "0"+hours : hours  //ternary operator
            mins = mins <10 ? "0"+mins : mins
            secs = secs <10 ? "0"+secs : secs
    
            this.currentTime = `${hours}:${mins}:${secs} ${ampm}`  // backticks are used to append java-script variable with the string

            if(this.alarmTime === `${hours}:${mins} ${ampm}`){
                console.log("Alarm Triggered!!")
                this.isAlarmTriggered = true
                this.ringtone.play()
                this.ringtone.loop = true
            }
        }, 1000)
    }

    createHoursOption(){
        for(let i=1; i<=12; i++){
            let val = i<10 ? "0"+i : i
            this.hour.push(val)
        }
    }
    createMinutesOption(){
        for(let i=0; i<=59; i++){
            let val = i<10 ? "0"+i : i
            this.minute.push(val)
        }
    }

    optionhandler(event){
        const{label, value} = event.detail  
        if(label === "Hour(s)"){
            this.hourSelected = value
        }else if(label === "Minute(s)"){
            this.minuteSelected = value
        }else if(label === "AM/PM"){
            this.meridiemSelected = value
        }else{}     

        console.log("this.hourSelected - - ", this.hourSelected)
        console.log("this.minuteSelected - - ", this.minuteSelected)
        console.log("this.meridiemSelected - - ", this.meridiemSelected)

    }

    setAlarmHandler(){
        this.alarmTime = `${this.hourSelected}:${this.minuteSelected} ${this.meridiemSelected}`
        this.isAlarmSet = true
    }
    clearAlarmHandler(){
        this.alarmTime = ''
        this.isAlarmSet = false
        this.isAlarmTriggered = false
        this.ringtone.pause()
        const elements = this.template.querySelectorAll('c-clock-dropdown')// This returns a note like array so convert the result in array first.
        Array.from(elements).forEach(element=>{
           element.reset("") 
        })
    }
}