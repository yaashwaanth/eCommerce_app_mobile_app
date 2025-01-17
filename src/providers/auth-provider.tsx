// import { Session } from "@supabase/supabase-js";
// import { createContext, PropsWithChildren, useContext, useEffect, useState } from "react";
// import { supabase } from "../lib/supabase";

// type AuthData ={
//     session: Session | null;
//     mounting: boolean;
//     user: any
// }

// const AuthContext = createContext<AuthData>({
//     session: null,
//     mounting: true,
//     user: null
// })

// export default function AuthProvider({children}: PropsWithChildren) {

//     const [session,setSession] = useState<Session| null>(null);
//     const [user,setUser] = useState<{
//       avatar_url: string;
//     created_at: string | null;
//     email: string;
//     // expo_notification_token: string | null;
//     id: string;
//     // stripe_customer_id: string | null;
//     type: string | null;
//     } | null>(null);

//     const [mounting,setMounting] = useState(true);
 

//     useEffect(() => {
//       console.log("auth-provider Mounted->");
      
//       const fetchSession = async()=> {
//         console.log("fectSession funciton call");     
//         const {data: {session},error} = await supabase.auth.getSession();
//         console.log("session loaded",error);
     
//         // setSession(session)
        
//         if(session){
//           // getting user
//             const {data: user,error} = await supabase.from('users').select("*").eq('id',session.user.id).single()
//             console.log("user ->",user);
            
//         if(error){
//             console.log('error',error);
            
//         }else{
//             setUser(user);
//         }
//         }
//         setMounting(false);

//       }

      
//       fetchSession();

      
//       supabase.auth.onAuthStateChange((_event,session)=>{
//         setSession(session);
//       })
//     }, [])

//     return <AuthContext.Provider value={{session,mounting,user}}>{children}</AuthContext.Provider>
    

    
// }

// export const useAuth = () => useContext(AuthContext);

import { Session } from "@supabase/supabase-js";
import { createContext, PropsWithChildren, useContext, useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

type UserType = {
  avatar_url: string;
  created_at: string | null;
  email: string;
  id: string;
  type: string | null;
};

type AuthData = {
  session: Session | null;
  mounting: boolean;
  user: UserType | null;
};

const AuthContext = createContext<AuthData>({
  session: null,
  mounting: true,
  user: null,
});

export default function AuthProvider({ children }: PropsWithChildren) {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<UserType | null>(null);
  const [mounting, setMounting] = useState(true);

  useEffect(() => {
    console.log("AuthProvider Mounted");

    const fetchSessionAndUser = async () => {
      try {
        const {
          data: { session: fetchedSession },
          error: sessionError,
        } = await supabase.auth.getSession();

        

        if (sessionError) throw sessionError;

        setSession(fetchedSession);
        console.log(session,"_>session");


        if (fetchedSession) {
          const { data: userData, error: userError } = await supabase
            .from("users")
            .select("*")
            .eq("id", fetchedSession.user.id)
            .single();

          if (userError) throw userError;

          setUser(userData);
        }
      } catch (error) {
        console.error("Error fetching session or user:", error);
      } finally {
        setMounting(false);
      }
    };

    fetchSessionAndUser();

    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        setSession(session);
        if (session) {
          try {
            const { data: userData, error: userError } = await supabase
              .from("users")
              .select("*")
              .eq("id", session.user.id)
              .single();

            if (userError) throw userError;

            setUser(userData);
          } catch (error) {
            console.error("Error fetching user on auth change:", error);
          }
        } else {
          setUser(null);
        }
      }
    );

    
  }, []);

  return (
    <AuthContext.Provider value={{ session, mounting, user }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
