import React from 'react';
import {Logo, Profil, Logout } from '../../atom';

const Navbar = () => {
    return(    
            <div classname="z-40 bg-white w-full border-b-2 border-gray-300 px-10">
                <div className="flex justify-between  items-center px-10">
                    <div className="flex items-center">
                        <Logo/>
                        <p className="font-semibold text-4xl">Storage</p>
                    </div>
                    <div className="flex items-center">
                        <Profil><Logout/></Profil>
                    </div>
                </div>
            </div>
    )
}
export default Navbar