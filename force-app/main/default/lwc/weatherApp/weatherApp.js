import { LightningElement } from 'lwc';
import weatherAppIcons from '@salesforce/resourceUrl/weatherAppIcons'; 
import getWeatherDetails from '@salesforce/apex/weatherAppController.getWeatherDetails';

const API_KEY = '2334defe372c420b29577995b66e9fb7'

export default class WeatherApp extends LightningElement {
    clearIcon = weatherAppIcons+'/weatherAppIcons/clear.svg' 
    arrowBackIcon = weatherAppIcons+'/weatherAppIcons/arrow-back.svg'
    cloudIcon = weatherAppIcons+'/weatherAppIcons/cloud.svg'
    dropletIcon = weatherAppIcons+'/weatherAppIcons/droplet.svg'
    hazeIcon = weatherAppIcons+'/weatherAppIcons/haze.svg'
    mapIcon = weatherAppIcons+'/weatherAppIcons/map.svg'
    rainIcon = weatherAppIcons+'/weatherAppIcons/rain.svg'
    snowIcon = weatherAppIcons+'/weatherAppIcons/snow.svg'
    stormIcon = weatherAppIcons+'/weatherAppIcons/storm.svg'
    thermometerIcon = weatherAppIcons+'/weatherAppIcons/thermometer.svg'

    cityName = ''
    loadingText = ''
    isError = false
    response
    weatherIcon

    //getter always return something
    get loadingClasses(){
        return this.isError ? 'loadingTextError' : 'loadingTextSuccess' // Ternary Operator
    }   

    searchHandler(event){
        this.cityName = event.target.value
        //console.log("this.cityName", this.cityName);
    }

    submitHandler(event){
        //Form tag has a default property of refreshing a page so to prevent tht we have to use following 
        event.preventDefault()
        this.fetchData()
    }
    async fetchData(){
        this.isError = false
        this.loadingText = 'Fetching weather details.....'
        console.log("cityName -->", this.cityName)
        //const URL = `https://api.openweathermap.org/data/2.5/weather?q=${this.cityName}&units=metric&appid=${API_KEY}`
        
        getWeatherDetails({input : this.cityName}).then(result =>{
            console.log('result', result)
            this.weatherDetails(JSON.parse(result));
        }).catch((error)=>{
            this.response = null
            console.log("error has occured", error)
            this.loadingText = "error has occured"
            this.isError = true
        })
        //Below is another way to use fetch method

        /*const data = await fetch(URL) 
        const JSONdata = await data.json()  
        console.log('JSONdata', JSONdata) */

        //Below is client side call which means we can make call to api from the JS file directly but the problem is the api key will be visible directly in the inspect to everyone which can lead to misuse of the api-key

        /*fetch(URL).then(res=>res.json()).then(result=>{
            console.log(JSON.stringify(result))
            this.weatherDetails(result)
        }).catch((error)=>{
            console.log("error has occured", error)
            this.loadingText = "error has occured"
            this.isError = true
        })*/ 
    }

    weatherDetails(info){
        if(info.cod === '404'){
            this.isError = true
            this.loadingText = `${this.cityName} isn't a valid city name`
        }else{
            this.isError = false
            this.loadingText = ''
            const city = info.name
            const country = info.sys.country
            const {description, id} = info.weather[0]
            const {temp, feels_like, humidity} = info.main
            if(id === 800){
                this.weatherIcon = this.clearIcon
            }
            else if(id >= 801 && id <= 804){
                this.weatherIcon = this.cloudIcon
            }
            else if((id >= 200 && id <= 232) || (id >= 600 && id <= 622)){
                this.weatherIcon = this.stormIcon
            }
            else if((id >= 500 && id <= 531) || (id >= 300 && id <= 321)){
                this.weatherIcon = this.rainIcon
            }
            else if(id >= 701 && id <= 781){
                this.weatherIcon = this.hazeIcon
            }
            else if(id >= 600 && id <= 622){
                this.weatherIcon = this.snowIcon
            }
            else{

            }

            this.response = {
                city : city,
                temperature : Math.floor(temp),
                description : description,
                location : `${city}, ${country}`,
                feels_like : Math.floor(feels_like),
                humidity : `${humidity}%`
            }
        }
    }

    backHandler(){
        this.response = null
        this.cityName = ''
        this.loadingText = ''
        this.isError = false
        this.weatherIcon 
    }
}