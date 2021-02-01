import React from 'react';
import { Component } from 'react';
import axios from 'axios';

class Upfolder extends Component{

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
        url : 'http://192.168.0.188:12345/upload_folder/?Username='+ (this.state.Username) + '&Path='+(this.state.path),
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
// async replace(){
//     await this.handleUpload()
//     window.location.reload()
//   }
render(){
    return(
    <div className="bg-white absolute rounded-lg w-96 h-50 shadow p-5 space-y-10">
        <h1 className="text-center">Upload Folder</h1>
            <div className ="space-y-10">
               <div>
                   <label> Select Folder</label>
                   <input directory="" webkitdirectory="" mozdirectory="" type="file" name="myfiles"  value={this.state.folder} onChange={(e)=>this.handleFile(e)} className="border-2" />
               </div>
               <div>
                    <button type="submit" onClick={(e)=>this.handleUpload(e)} className="shadow px-3 py-2 rounded-lg">Upload</button>
               </div>
            </div> 
            {/* <form method="post" action="http://192.168.0.188:12345/upload_folder/?Username=snk&Path=" enctype="multipart/form-data">
            <label>The file :</label>
            <input type="file" name="myfiles" webkitdirectory mozdirectory directory required /><br />
            <button type="submmit">Submit</button>
        </form> */}
    </div>
    )
}
}
export default Upfolder