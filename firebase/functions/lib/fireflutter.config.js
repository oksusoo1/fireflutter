"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.config = void 0;
exports.config = {
    adminSdkKey: {
        type: "service_account",
        project_id: "wonderful-korea",
        private_key_id: "bcebed3c77cd76cde2d6a5010f33ae9821ea545a",
        private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCbpQ63bXWtSvvS\nNe/smc6SHOGRCLT77r3AQG6v7HYxpYy7MT5wpCAnhnGkIRd5CysdCoSCRWFucRGZ\ncz4cF7251i/YLepDati89L/2Y9/Rn8dqO8x+zYU/9zPtPsG+8x5rC4LJn4Z5u0W4\nMhlQTDeWmVY4nqdQtT5sG2Rl3ETUrd3SR05wpwRATIQTabxMD1dmllk7Wdgho9tV\nxfeMEspQ5ZOB8cVO2f5n9dlvv1VAKQjjSIUeU0bDgSbyz6u0Z35H+1otFuUjA+E9\nNtOgPoZHLBYbiMsWlXjWYrXe3TrSju62wHfD6btBe0rgPlaAKAaFEgaHT4umyquN\nFoc9q6oRAgMBAAECggEAA8oHazDHgiIGsm3suuJdtJHubeT73vxHc1Q+PZswn3HL\n1MzUm9JrE/tCbf/+PcynTowwgKlmv1USXB2BoBZ14H3V6Vnoz55cy3Db8Ygp7UUK\nCkyNZHLlcRK4GWkDN35cubdshjMTh4gnIN5bXmiUm958ymEWarEW5XPfRFmR9WmC\neTHnALgs/TZ9aJugWLg/FTw/7cZC4hd3I41kMJNPBwWZ1jQcqhDcd+/Tuwer0LVU\nmi1WvuyRXXX7Sj1Y6OVCBQp6HG/8Io/JGU1jO6sDojlzZPgJE6uK2Ek9yxrPf5hS\n2R34M39F2VPJTyalPG0P1JZ1rLeJe1SAt2t1Cjzr/wKBgQDNwiq8Ukz5HoboaS3/\nPL0aatqHTOp5AEbTqT70l43IfHCjPV+guELV2xDDI1Gh6n4V2SgIsEAXdmdf6JMG\nzmKKz8IEO/PKiJsGeUF9itZo1IMF0ocgVVO2+JaPYufNLLuh7UbHQIF/s78+xC3f\nrLTM40fzQWOesrk4A0Y+82fNxwKBgQDBplBdZAoGap7CZfSqeOIdTBD+StMRGClo\nbFePMeR1it6JxVdb1c3d5Ii4dR5h2EBwq/OScyi4FM6Q2ijieQvIqVKVF97mh300\nw7hHZLXOJYzOHKcqR9s5/d+2bwaUfftXd28MdQ0KcIK+ip9dOPfMBQ/o4rqOEVpe\nc5AwRXUpZwKBgDWKCY65J5hHDjmZbMOWbWpbVYORSw2zObrHtj701IrPfourY5+x\ncoqtFv5/yTUFjEtpFxazremtAJcfMGq79z5Bcy2g3/3ab+ROVvEw2Dus2G8CafDK\n4x6gLqUeykxEEIrA8ALW0RuGjQPrDji+esk5drZgVGit/q4JhBTLRz5vAoGALDmG\nSv3IyFRbM3xDVxdKVHSFwP1nnJTPCBkOGhbD3RA86GvYGpIGdPF3Q+EDckcH2HN8\nqeqA1yFxV2VrRuVsCoSY5pHQBwfUUVONZ0iZuJ2cvYmPp7lHWMQg7jIG56yp1Pzi\nsI6ezs6JHWjdIlYbSU2yp3X4Mu/FmqJ7wHpsWmsCgYEAs/HOugORPAv7tATnX4N5\n0gLaOcDAX24V7GgEyiBRxVqQeHD0R0IvXY1rriiRsbEYnKm52nRLVZhsDbIlzW1N\n8Z/s7NAqRDq3d/wV7O+aaW/nk7kc7VKeutQnJltoSAEpf3Uy22D/sbW4c/6YsOtJ\nnnOxMXS6Zb494urBpZXMko8=\n-----END PRIVATE KEY-----\n",
        client_email: "firebase-adminsdk-milc8@wonderful-korea.iam.gserviceaccount.com",
        client_id: "102920905325518117924",
        auth_uri: "https://accounts.google.com/o/oauth2/auth",
        token_uri: "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-milc8%40wonderful-korea.iam.gserviceaccount.com",
    },
    // adminSdkKey: {
    //   // test
    //   project_id: "wonderful-korea",
    //   private_key:
    //     "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCbpQ63bXWtSvvS\nNe/smc6SHOGRCLT77r3AQG6v7HYxpYy7MT5wpCAnhnGkIRd5CysdCoSCRWFucRGZ\ncz4cF7251i/YLepDati89L/2Y9/Rn8dqO8x+zYU/9zPtPsG+8x5rC4LJn4Z5u0W4\nMhlQTDeWmVY4nqdQtT5sG2Rl3ETUrd3SR05wpwRATIQTabxMD1dmllk7Wdgho9tV\nxfeMEspQ5ZOB8cVO2f5n9dlvv1VAKQjjSIUeU0bDgSbyz6u0Z35H+1otFuUjA+E9\nNtOgPoZHLBYbiMsWlXjWYrXe3TrSju62wHfD6btBe0rgPlaAKAaFEgaHT4umyquN\nFoc9q6oRAgMBAAECggEAA8oHazDHgiIGsm3suuJdtJHubeT73vxHc1Q+PZswn3HL\n1MzUm9JrE/tCbf/+PcynTowwgKlmv1USXB2BoBZ14H3V6Vnoz55cy3Db8Ygp7UUK\nCkyNZHLlcRK4GWkDN35cubdshjMTh4gnIN5bXmiUm958ymEWarEW5XPfRFmR9WmC\neTHnALgs/TZ9aJugWLg/FTw/7cZC4hd3I41kMJNPBwWZ1jQcqhDcd+/Tuwer0LVU\nmi1WvuyRXXX7Sj1Y6OVCBQp6HG/8Io/JGU1jO6sDojlzZPgJE6uK2Ek9yxrPf5hS\n2R34M39F2VPJTyalPG0P1JZ1rLeJe1SAt2t1Cjzr/wKBgQDNwiq8Ukz5HoboaS3/\nPL0aatqHTOp5AEbTqT70l43IfHCjPV+guELV2xDDI1Gh6n4V2SgIsEAXdmdf6JMG\nzmKKz8IEO/PKiJsGeUF9itZo1IMF0ocgVVO2+JaPYufNLLuh7UbHQIF/s78+xC3f\nrLTM40fzQWOesrk4A0Y+82fNxwKBgQDBplBdZAoGap7CZfSqeOIdTBD+StMRGClo\nbFePMeR1it6JxVdb1c3d5Ii4dR5h2EBwq/OScyi4FM6Q2ijieQvIqVKVF97mh300\nw7hHZLXOJYzOHKcqR9s5/d+2bwaUfftXd28MdQ0KcIK+ip9dOPfMBQ/o4rqOEVpe\nc5AwRXUpZwKBgDWKCY65J5hHDjmZbMOWbWpbVYORSw2zObrHtj701IrPfourY5+x\ncoqtFv5/yTUFjEtpFxazremtAJcfMGq79z5Bcy2g3/3ab+ROVvEw2Dus2G8CafDK\n4x6gLqUeykxEEIrA8ALW0RuGjQPrDji+esk5drZgVGit/q4JhBTLRz5vAoGALDmG\nSv3IyFRbM3xDVxdKVHSFwP1nnJTPCBkOGhbD3RA86GvYGpIGdPF3Q+EDckcH2HN8\nqeqA1yFxV2VrRuVsCoSY5pHQBwfUUVONZ0iZuJ2cvYmPp7lHWMQg7jIG56yp1Pzi\nsI6ezs6JHWjdIlYbSU2yp3X4Mu/FmqJ7wHpsWmsCgYEAs/HOugORPAv7tATnX4N5\n0gLaOcDAX24V7GgEyiBRxVqQeHD0R0IvXY1rriiRsbEYnKm52nRLVZhsDbIlzW1N\n8Z/s7NAqRDq3d/wV7O+aaW/nk7kc7VKeutQnJltoSAEpf3Uy22D/sbW4c/6YsOtJ\nnnOxMXS6Zb494urBpZXMko8=\n-----END PRIVATE KEY-----\n",
    //   client_email: "firebase-adminsdk-milc8@wonderful-korea.iam.gserviceaccount.com",
    // },
    databaseURL: "https://wonderful-korea-default-rtdb.asia-southeast1.firebasedatabase.app/",
    storageBucket: "wonderful-korea.appspot.com",
    serverKey: "AAAAYFrHrGQ:APA91bHlkaciFeyxQql9DauveMESUP0lDBYc8jwatouTpWthY97mCYqEskRBiUUeXvHowEzCZjjOPO-xOhwh8ZXQl8Dtr8DyBS90_wtDnpBDcIwYw60piye1n4DvkVWCQ_MSSvVHIUw0",
};
//# sourceMappingURL=fireflutter.config.js.map