// import './assets/output.css'
import React from 'react';
import axios from 'axios'
import { Component } from 'react';
import { data } from 'autoprefixer';
import Api2 from './login2';

// const api = axios.create({
//     baseURL : 'http://192.168.0.188:12345/delete_file/'
// })
let config = {
    File_id: 1,
    Username: 'akdev'
}

// let api2 = axios({
//     method: 'get',
//     url: 'http://192.168.0.188:12345/delete_file/',
//     params: config,
// })

class Coba extends Component{    
    // state = {
    //     api2:
    // }
    coba = async()=>{
        let api2 = await axios({
        method: 'get',
        url: 'http://192.168.0.188:12345/delete_file/',
        params: config,
        })
        console.log(api2)
    }
    // constructor(){
    //     super();
    //     this.state
        // api.get('/',{file_id: 1,username:'akdev'}).then(res => {
        //     console.log(res)
        //     // this.setState({courses: res.data})
        // }).catch(error => {
        //     console.log(error)
        // })
        // api2.then(res => {
        //     console.log(res)
        // }).catch(error => {
        //     console.log(error)
        // })
    // }
render(){
 return(
     <div>
         <h1>bisalah Tolong</h1>
         <button onClick={this.coba}> bisalah</button>
         <ul>
         </ul>
            
     </div>
 )
}
}

export default Coba