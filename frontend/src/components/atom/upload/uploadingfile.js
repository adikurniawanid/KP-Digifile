import React from 'react';
import { Component } from 'react';
import axios from 'axios';

class Upfile extends Component{

state = {
    file : [],
    Username : sessionStorage.getItem("Usernameuser"),
    path : sessionStorage.getItem("Current")
}
handleFile(e){
    let file = e.target.files
    this.setState({file:file})
    console.log(file)
}
async handleUpload(e){
    let file = this.state.file
    let formdata = new FormData()
    for (let i = 0; i < this.state.file.length; i++) {
        formdata.append('myfiles', file[i])
    }
    await axios({
        url : 'http://192.168.0.188:12345/upload_file/?Username='+ (this.state.Username) + '&Path='+(this.state.path),
        method: "POST",
        data : formdata
    }).then((res)=>{
        console.log("Berhasil")
        console.log(res)

    }
    ,(err)=>{
        console.log("masig Errror")
    }
    )
    window.location.reload()
}

render(){
    return(
    <div className="bg-white absolute rounded-lg w-96 h-50 shadow p-5 space-y-10">
        <h1 className="text-center">Upload File</h1>
            <div className ="space-y-10">
               <div>
                   <label> Select File</label>
                   <input type="file" multiple name="myfiles" onChange={(e)=>this.handleFile(e)}></input>
               </div>
               <div>
                    <button type="submit" onClick={(e)=>this.handleUpload(e)} className="shadow px-3 py-2 rounded-lg">Upload</button>
               </div>
            </div> 
    </div>
    )
}
}
export default Upfile