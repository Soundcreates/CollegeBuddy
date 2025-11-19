import axios from "axios";

const server = axios.create({
    baseURL: "http://localhost:8080",
    withCredentials: true,
});

export default server;