import React, {Component} from 'react';
import axios from 'axios';

class Login extends Component{
  state = {
    Username : null,
    Fullname : null,
    Password : null,
    courses : null,
  };

  hendleChange = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }
  
  async componentWillMount(){
      const params = new URLSearchParams()
      params.append('Username', sessionStorage.getItem("Usernameuser"))
      await axios.put('http://192.168.0.188:12345/set_offline/?',params)
        .then(res =>{
          this.setState({courses : res.data.data})
          console.log(res)
        })
        sessionStorage.removeItem("Usernameowner")
        sessionStorage.removeItem("Usernameuser")
        sessionStorage.removeItem("Fullname")
  }

  handleSubmit(){
    const params = new URLSearchParams()
    params.append('Username', this.state.Username)
    params.append('Password', this.state.Password)
    // axios.put('http://192.168.0.188:12345/login/',params)
    axios.post('http://192.168.0.188:12345/login/',params)
      .then(res => {
        this.setState({courses : res.data.data})
        this.handlePage()
        
    })   
    axios.get('http://192.168.0.188:12345/get_name/?', {params :{ 
      Username : this.state.Username
    }}).then(res => {
      sessionStorage.setItem("Fullname", res.data.data)
      this.setState({Fullname : res.data.data})
      console.log(res.data.data)
    })
  }

  handlePage(){
    if(this.state.courses ===2){
      sessionStorage.setItem("Usernameuser",this.state.Username);
        this.props.history.push("/user")
      }
      else if ((this.state.courses ===1)){
        sessionStorage.setItem("Usernameowner",this.state.Username);
        this.props.history.push("/owner")
      }
  }

  onClick =() =>{
    this.handleSubmit();
    // this.handlePage();
    console.log("diklik login")
  }

  render(){
  return (
    <div className="container items-center bg-primary rounded-lg md:w-1/4 w-full  h-auto m-auto mt-20 text-center py-20">
      <h1 className = "text-3xl text-shadow-md text-white font-body font-bold">Sign In</h1>
      {/* <form> */}
        <input className = "bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mt-5 placeholder-gray-200::placeholder focus:outline-none" type = "username" placeholder = "username" 
        name="Username"
        value={this.state.username}
        onChange={this.hendleChange}>
        </input>
        <input className = "bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mt-5 placeholder-gray-200::placeholder focus:outline-none" type = "password" placeholder = "password  " 
        name="Password"
        value={this.state.password}
        onChange={this.hendleChange}>
        </input>
        <div>
        <button className ="bg-gray-500 mt-5 mb-6 py-3 px-5 rounded-lg font-bold" 
        type = "submit"
        onClick={this.onClick}>
          Log in
        </button>
        {
          this.state.courses ===0 &&
          <p className="text-white">Username atau Password Salah</p>
        }
        </div>
     {/* </form> */}
    </div>
  );
}
}

export default Login;