import React from 'react';
import { Component } from 'react';
import axios from 'axios';

class Renamefile extends Component{
state = {
    folder : null,
    Username : sessionStorage.getItem("Usernameuser"),
    path : sessionStorage.getItem("Current")
}
handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
    
  }
  async handleUpload(){
    await axios.get('http://192.168.0.188:12345/create_folder/',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Curent_path : sessionStorage.getItem("Current"),
        Folder_name : this.state.folder,
      }}).then(res=>{
        this.setState({courses : res.data.data})
        console.log(res)
        console.log(sessionStorage.getItem("Current"))
      },(err)=>{
          console.log("gagal untuk Upload")
      }
      )
    window.location.reload()

  }
render(){
    return(
    <div className="bg-white absolute rounded-lg w-96 h-50 shadow p-5 space-y-10">
        <h1 className="text-center">Rename File</h1>
            <div className ="space-y-10">
               <div>
                   <label>Masukkan Nama File</label>
                   <input type="input" name="folder" value={this.state.folder} onChange={this.handleChane} className="border-2"></input>
               </div>
               <div>
                    <button type="submit" onClick={(e)=>this.handleUpload(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
               </div>
            </div> 
    </div>
    )
}
}
export default Renamefile