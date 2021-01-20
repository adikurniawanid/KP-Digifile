import React from 'react';
import { FaPenSquare } from "react-icons/fa";

function Edit() {
    return(
      <button className ="bg-gray-400 w-10 h-5 rounded-lg text-sm items-center mt-1 focus:outline-none" type = "submit" name="login"><FaPenSquare className="m-auto"/></button>
    )
}

export default Edit