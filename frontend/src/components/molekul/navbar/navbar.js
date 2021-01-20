import React from 'react';
import { Search, Logo, Profil } from '../../atom';

const Navbar = () => {
    return(    
            <nav class="container bg-white w-full border-b-2 border-gray-300 px-10">
                <div className="flex justify-between items-center">
                    <div className="flex items-center">
                        <Logo/>
                        <p className="font-semibold text-4xl">Storage</p>
                    </div>
                    <div className="flex items-center">
                        <Search text = "Search"/>
                        <Profil/>
                    </div>
                </div>
            </nav>
    )
}

export default Navbar