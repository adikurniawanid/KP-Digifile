import React from 'react';
import { Component } from 'react';
import axios from 'axios'

class Logout extends Component {
    async logout(){
        const params = new URLSearchParams()
        params.append('Username', sessionStorage.getItem("Usernameuser"))
        await axios.put('http://192.168.0.188:12345/set_offline/?',params)
    
        sessionStorage.removeItem("Usernameowner")
        sessionStorage.removeItem("Usernameuser")
        sessionStorage.removeItem("Fullname")
        window.location.reload()
        
    }
    render(){
    return(
        <div className="absolute px-5 py-2 w-40 h-20 mt-20 -ml-10 basolut bg-white rounded-lg shadow items-center">
            <button onClick={this.logout}>Log Out</button>
      </div>
    )
}
}

export default Logout
