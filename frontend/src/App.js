import './assets/output.css'
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import User from './pages/user/user';
import Owner from './pages/owner/owner';
import Login2 from './pages/login/login2';
import Login from './pages/login/login';

function App() {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/" component={Login}/>
        <Route path= "/user" component={User}/>
        <Route path= "/owner" component={Owner}/>
      </Switch>
    </BrowserRouter>
  );
}

export default App;
