import React, {Component} from 'react';
import axios from 'axios';

const api2 = axios.create({
  baseURL : 'http://192.168.0.188:12345/login/'
})
// const api2 =null;
class Login extends Component{
  state = {
    Username : null,
    Password : null,
    courses : [],
  };

  hendleChange = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }


  coba = async()=>{
    let api = await axios({
    method: 'get',
    url: 'http://192.168.0.188:12345/login/',
    params: this.state,
    })
    console.log(api)
}
constructor(){
          super();
          api2.get('/').then(res => {
              console.log(res.data)
              this.setState({courses: res.data})
          })
      }
  render(){
  return (
    <div className="container items-center bg-primary rounded-lg md:w-1/4 w-full  h-auto m-auto mt-20 text-center py-20">
      <h1 className = "text-3xl text-shadow-md text-white font-body font-bold">Sign In</h1>
      {/* <form className="block"> */}
        <input className = "bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mt-5 placeholder-gray-200::placeholder focus:outline-none" type = "username" placeholder = "username" 
        name="username"
        // value={this.state.username}
        onChange={this.hendleChange}>
        </input>
        <input className = "bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mt-5 placeholder-gray-200::placeholder focus:outline-none" type = "password" placeholder = "password  " 
        name="password"
        // value={this.state.password}
        onChange={this.hendleChange}>
        </input>
        <div>
        <button className ="bg-gray-500 mt-5 mb-6 py-3 px-5 rounded-lg font-bold" 
        type = "submit"
        onClick={this.coba}
        >Log in</button>
        {/* {alert(this.state.courses.data)} */}
        {/* <Buttonlog  text = "log In"/> */}
        </div>
      {/* </form> */}
      {/* <p>{this.state.username}</p>
      <p>{this.state.password}</p> */}
      <p>{this.state.courses.data}</p>
    </div>
  );
}
}

export default Login;