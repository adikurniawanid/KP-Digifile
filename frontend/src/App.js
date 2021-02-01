import './assets/output.css'
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import User from './pages/user/user';
import Owner from './pages/owner/owner';
import Login from './pages/login/login';
import { Component } from 'react';
import Edit from './pages/login/Tab';



class App extends Component{
  render(){
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/" component={Login}/>
        <Route exact path="/file" component={Edit}/>
        <Route path= "/user" component={User}/>
        <Route path= "/owner" component={Owner}/>
      </Switch>
    </BrowserRouter>
  );
}
}

export default App;
