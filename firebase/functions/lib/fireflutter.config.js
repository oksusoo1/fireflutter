"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.config = void 0;
// wonderfulkorea
exports.config = {
    adminSdkKey: {
        // type: "service_account",
        projectId: "wonderful-korea",
        clientEmail: "firebase-adminsdk-milc8@wonderful-korea.iam.gserviceaccount.com",
        privateKey: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCbpQ63bXWtSvvS\nNe/smc6SHOGRCLT77r3AQG6v7HYxpYy7MT5wpCAnhnGkIRd5CysdCoSCRWFucRGZ\ncz4cF7251i/YLepDati89L/2Y9/Rn8dqO8x+zYU/9zPtPsG+8x5rC4LJn4Z5u0W4\nMhlQTDeWmVY4nqdQtT5sG2Rl3ETUrd3SR05wpwRATIQTabxMD1dmllk7Wdgho9tV\nxfeMEspQ5ZOB8cVO2f5n9dlvv1VAKQjjSIUeU0bDgSbyz6u0Z35H+1otFuUjA+E9\nNtOgPoZHLBYbiMsWlXjWYrXe3TrSju62wHfD6btBe0rgPlaAKAaFEgaHT4umyquN\nFoc9q6oRAgMBAAECggEAA8oHazDHgiIGsm3suuJdtJHubeT73vxHc1Q+PZswn3HL\n1MzUm9JrE/tCbf/+PcynTowwgKlmv1USXB2BoBZ14H3V6Vnoz55cy3Db8Ygp7UUK\nCkyNZHLlcRK4GWkDN35cubdshjMTh4gnIN5bXmiUm958ymEWarEW5XPfRFmR9WmC\neTHnALgs/TZ9aJugWLg/FTw/7cZC4hd3I41kMJNPBwWZ1jQcqhDcd+/Tuwer0LVU\nmi1WvuyRXXX7Sj1Y6OVCBQp6HG/8Io/JGU1jO6sDojlzZPgJE6uK2Ek9yxrPf5hS\n2R34M39F2VPJTyalPG0P1JZ1rLeJe1SAt2t1Cjzr/wKBgQDNwiq8Ukz5HoboaS3/\nPL0aatqHTOp5AEbTqT70l43IfHCjPV+guELV2xDDI1Gh6n4V2SgIsEAXdmdf6JMG\nzmKKz8IEO/PKiJsGeUF9itZo1IMF0ocgVVO2+JaPYufNLLuh7UbHQIF/s78+xC3f\nrLTM40fzQWOesrk4A0Y+82fNxwKBgQDBplBdZAoGap7CZfSqeOIdTBD+StMRGClo\nbFePMeR1it6JxVdb1c3d5Ii4dR5h2EBwq/OScyi4FM6Q2ijieQvIqVKVF97mh300\nw7hHZLXOJYzOHKcqR9s5/d+2bwaUfftXd28MdQ0KcIK+ip9dOPfMBQ/o4rqOEVpe\nc5AwRXUpZwKBgDWKCY65J5hHDjmZbMOWbWpbVYORSw2zObrHtj701IrPfourY5+x\ncoqtFv5/yTUFjEtpFxazremtAJcfMGq79z5Bcy2g3/3ab+ROVvEw2Dus2G8CafDK\n4x6gLqUeykxEEIrA8ALW0RuGjQPrDji+esk5drZgVGit/q4JhBTLRz5vAoGALDmG\nSv3IyFRbM3xDVxdKVHSFwP1nnJTPCBkOGhbD3RA86GvYGpIGdPF3Q+EDckcH2HN8\nqeqA1yFxV2VrRuVsCoSY5pHQBwfUUVONZ0iZuJ2cvYmPp7lHWMQg7jIG56yp1Pzi\nsI6ezs6JHWjdIlYbSU2yp3X4Mu/FmqJ7wHpsWmsCgYEAs/HOugORPAv7tATnX4N5\n0gLaOcDAX24V7GgEyiBRxVqQeHD0R0IvXY1rriiRsbEYnKm52nRLVZhsDbIlzW1N\n8Z/s7NAqRDq3d/wV7O+aaW/nk7kc7VKeutQnJltoSAEpf3Uy22D/sbW4c/6YsOtJ\nnnOxMXS6Zb494urBpZXMko8=\n-----END PRIVATE KEY-----\n",
        private_key_id: "bcebed3c77cd76cde2d6a5010f33ae9821ea545a",
    },
    databaseURL: "https://wonderful-korea-default-rtdb.asia-southeast1.firebasedatabase.app/",
    storageBucket: "wonderful-korea.appspot.com",
};
// withcenter test project
// export const config = {
//   adminSdkKey: {
//     projectId: "withcenter-test-project",
//     clientEmail: "firebase-adminsdk-w66do@withcenter-test-project.iam.gserviceaccount.com",
//     privateKey:
//       "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCphvIWn/8E38EX\nZf6o+MhKU4AvtBo6au4ur0xQL99xpdwvERtHo1kvAU4YXHNlhGX/MaRj3qBxEKVa\nInXuqLyrYZX/FRlR/4IJb63Qm8PFC7ixtXrBbK89s4D/ygBHmCQnHCEmatW9ul2S\nEmUoh9Bo4GL3lrYquK9ntuUjTTsl/rcBKNO4Ta/NPoamxe7gU6SnStvAh3Rnh3T5\nayWJgb4b5n/qB7mXW6vaZyestPpPaf1744mBzDQJKp+zKR9RlJ8O+pHu8lDxnQSp\nhXWjduZXNii5APA70e0X+dqPTB3NT5nqfqRDoJ/AuUkT1fWvm9RP2qF0/urO7Pit\nfXMBL+izAgMBAAECggEAGvojeiA518+3jX6omMEGNnW1N2Ikrlknz/wLW9NSbmZj\ndIX3Xl4LKiS+BbhokKYSCRsgOthJldR9S6uiMrldVLRxxybXYaoUSmYgNcsjyy6D\nVJw5jaA6/sma5JmDk+ENF8AtMkzb+JY4n68Xs+xw6M+UUCwGjyPWnd2H9ycqG3B7\n5K5fBYQKCkoWSHLuGbjhEiIk9zzksvIC4BqBbMLuhSfLwpG9AEYHr57RSaWVqOZt\nxYO7VlF4mKCcjIJxkZZEybpDb5UBt5OWg58Vywqi8qzHUQ21T2pAN9/BjzXuAhIV\ncSeK1wEuCk80CixoIGBs0FuvWYqAhqm//G9xO76iCQKBgQDT/uLme+xH2EquETox\nHusCc+wACUJbZx89ZZaTo1Pt6oiWAMlcZdVCvPOPZdrN/PzKOPnVMH0jDEhGaazz\nJD7jS/NDFFKe/KnG4H//THDChEb+JuLmar87c5IBOrtmhaSn4MczmZ7hAHkzIQGW\nCJ/vuWywt5eZifa58l7B9EkobQKBgQDMt1ly5Y516n4OR5qm/Ab9r9F3KYoTe4Rg\neEeCn9feFZJr86nwc0LPMJX2efyUleEecmxlWVDcQjMal1keHGbIy907Bhwwms5r\nMSJ9ubd3nptc/ophLRw6JQhApjJHS/xa5YjmNLiYGiKe743LOObmjoNaPK7ewP2k\nbKIAVRjhnwKBgQCmdp2qyCIn5BH4DvT3v0RgP7BP8vVVGmtwZYXQVk7AIgqwZtu2\nnwvPhNlnf15Jo17IV+btXU7Vp35VNAOnRI3RI0FYKewahWG3FW/MgzSDuSSZyuUe\nczHIOB6ssnaWsVgyrpEc1oLoQNvqpv881Xbo4VwUg4UZ/jhrmIKJoA2WHQKBgQCh\n4zRXSfVYhjFdNX61IoScxRbONwk70ueiKjvSrnjU5RY/TBdNULi6g99zZJA7KDM4\nEqBpnTH2nFsxYhJVX3xgueafMHvGbAVkexydc+oELGcMKTZhFn1F9dcK2OLVwt8z\nOmUCNxrrHW/XY/Urijn+hSCWkXpwKQnrpwSNYr4kXQKBgFDGm2I1KhzFzNWEBEtf\nA54X1ssrHHNoR6d9SGyrwfUcJauiDC/czm88nw+ra5EZ83S4p68Fjd2gcANCDwrd\ncTPBVJfg7Ag0oPEhWQVrXUiE7ccwY3GrhhuKvKW5nBn/CTace8kS1Bs1w8aLHgJa\n/thkSXP+I8jSBY8UzEit5xJi\n-----END PRIVATE KEY-----\n",
//   },
//   databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
//   storageBucket: "withcenter-test-project.appspot.com",
// };
//# sourceMappingURL=fireflutter.config.js.map