import React from 'react';
import { FaSearch } from "react-icons/fa"

function Search(props) {
    return(
        <div className = "flex bg-grey-300 rounded-lg items-center w-auto h-7 mx-10">
            <FaSearch />
            <input className="bg-transparent w-16 h-5 focus:outline-none" type = "input"  placeholder = {props.text} ></input>
        </div>
        
    )
}

export default Search