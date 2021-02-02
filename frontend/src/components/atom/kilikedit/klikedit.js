import axios from 'axios';
import React, {Component} from 'react';



class Akun extends Component{
  state = {
    Username : null,
    Nama : null,
    Email : null,
    Space : null,
    courses : null,
  };

  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }

  handleEdituser=()=>{
    const params = new URLSearchParams()
      params.append('Username', this.state.Username)
      params.append('Name', this.state.Nama)
      params.append('Space', this.state.Space)
      params.append('Email', this.state.Email)
    axios.put('http://192.168.0.188:12345/edit_user/',params)
        .then(res =>{
          console.log(res)
        })
    }
    replace(){
      window.location.reload()
    }
  render(){
  return (
              <div id="list" className="bg-white rounded-lg shadow pt-5">
                {/* <form> */}
                  <div className = "flex">
                    <div className = "block text-center"> 
                      <label className="block font-bold text-blue-400">Username</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Username"
                      name="Username"
                      value={this.state.Username}
                      onChange={this.handleChane}>
                    </input>
                    </div>
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Nama</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Nama" 
                      name="Nama"
                      value={this.state.Nama}
                      onChange={this.handleChane}>
                      </input>
                    </div>                    
                  </div>
                  <div className="flex">
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Email</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Email"
                      name="Email"
                      value={this.state.Email}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Space</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "number" placeholder = "Masukkan bilangan integer" 
                      name="Space"
                      value={this.state.Space}
                      onChange={this.handleChane}>
                      </input>
                    </div>

                  </div>
                    <div className="text-center">
                    <button className ="bg-gray-200 shadow my-2 py-1 px-2 rounded-lg font-bold m-auto" 
                    type = "submit"
                    onClick = {this.handleEdit}
                    >Edit</button>
                    </div>
                {/* </form>    */}
              </div>
  );
}
}

export default Akun