import React from 'react';

function Buttonlog(props) {
    return(
      
      <button href="http://localhost:3000/user" className ="bg-gray-500 mt-5 mb-6 py-3 px-5 rounded-lg font-bold" type = "submit" name="login"
      >{props.text}</button>
      
    )
}

export default Buttonlog