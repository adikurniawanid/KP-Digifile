import axios from 'axios';
import React, {Component} from 'react';
import { Link } from 'react-router-dom';



class Akun extends Component{
  state = {
    Username : null,
    Name : null,
    Password : null,
    Nohp : null,
    Email : null,
    Space : null,
    courses : null,
  };

  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }

  handleSubmit=()=>{
      const params = new URLSearchParams()
      params.append('Username', this.state.Username)
      params.append('Name', this.state.Name)
      params.append('Password', this.state.Password)
      params.append('Phone', this.state.Nohp)
      params.append('Email', this.state.Email)
      params.append('Space', this.state.Space)
      // axios.put('http://192.168.0.188:12345/login/',params)
      axios.post('http://192.168.0.188:12345/add_user/',params)
      .then(res =>{
        this.setState({courses : res.data.data})
        console.log(res.data)
        this.handleAdd()
      })
    }
    handleAdd(){
      if(this.state.courses ===2){
          return(
            alert ("Username Sudah Terdaftar"))
        }
        else if ((this.state.courses ===1)){
          // this.props.history.push("/owner")
            window.location.reload()
        }
        else {
            alert ("Data Salah")  
        }
    }
  

  render(){
  return (
              <div id="list" className="container absolute bg-white rounded-lg md:w-1/2 w-full  h-auto m-auto md:-mt-56 md:ml-64 -ml-5 pt-5 pl-5 shadow">
                <h1 className = "text-2xl text-shadow-md text-black font-bold text-center">Tambah akun</h1>
                {/* <form> */}
                <div className = "pl-10">
                  <div className="flex">
                    <div className = "block">
                      <label className="block font-bold text-blue-400">Username</label>
                      <input className = " block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Username" 
                      name="Username"
                      value={this.state.Username}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                    <div className = "block">
                      <label className="block font-bold text-blue-400">Nama</label>
                      <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Nama" 
                      name="Name"
                      value={this.state.Name}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                  </div>

                  <div className="flex">
                    <div className = "block">
                      <label className="block font-bold text-blue-400">Password</label>
                      <input className = " block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "password" placeholder = "Password" 
                      name="Password"
                      value={this.state.Password}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                    <div className = "block">
                      <label className="block font-bold text-blue-400">No.hp</label>
                      <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "number" placeholder = "Nohp" 
                      name="Nohp"
                      value={this.state.Nohp}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                  </div>

                  <div className="flex">
                    <div className = "block">
                      <label className="block font-bold text-blue-400">Email</label>
                      <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "email" placeholder = "Ex :..@email.com" 
                      name="Email"
                      value={this.state.Email}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                    <div className = "block">
                      <label className="block font-bold text-blue-400">Space</label>
                      <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "number" placeholder = "bilangan integer" 
                      name="Space"
                      value={this.state.Space}
                      onChange={this.handleChane}>
                      </input>
                    </div>
                  </div>
                </div>
                  <div>
                    <button className ="bg-gray-200 shadow mt-5 mb-6 py-1 px-2 rounded-lg font-bold m-auto" 
                    type = "submit"
                    onClick = {this.handleSubmit}
                    >Daftar</button>
                    {/* <p>{this.state.Username}</p> */}
                    </div>
                {/* </form>    */}
              </div>
  );
}
}

export default Akun