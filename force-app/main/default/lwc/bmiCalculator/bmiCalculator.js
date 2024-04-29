import { LightningElement } from 'lwc';

export default class BmiCalculator extends LightningElement {
height = ''
weight = ''
bmiValue = ''
result = ''

handleChange(event){
    const{name, value} = event.target
        if(name === "height"){
            this.height = value
        }
        if(name === "weight"){
            this.weight = value
        } 
}

handleSubmit(event){
    event.preventDefault()
    console.log("height", this.height)
    console.log("weight", this.weight)
    this.Calculate()
}

Calculate(){
    /* BMI = Weight in Kg / (Height in m * Height in m)*/
    let height = Number(this.height)/100; //divide by 100 to convert height from cm to m
    let bmi = Number(this.weight)/(height * height);

    this.bmiValue = Number(bmi.toFixed(2)) // to fixed property to set upto 2 decimal values only

    if(this.bmiValue < 18.5){
        this.result = "Underweight"
    }
    else if(this.bmiValue >= 18.5 && this.bmiValue < 25){
        this.result = "Healthy"
    }
    else if(this.bmiValue >= 25 && this.bmiValue <= 30){
        this.result = "Overweight"
    }
    else {
        this.result = "Obese"
    }
    console.log("BMI value is ==>>" +bmi);
    console.log("Result value is ==>>" +this.result);

}

recalculate(){
    this.height = ''
    this.weight = ''
    this.bmiValue = ''
    this.result = ''
}
}