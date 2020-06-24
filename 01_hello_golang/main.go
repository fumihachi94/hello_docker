/*------------------------------------------------
- HTTPリクエストに対して”Hello Docker!!”とレスポンスする。
- 8080ポートでサーバアプリケーションとして動作
- クライアントからリクエストを受けると、"received request"ログ表示

HTTPリクエストコマンド
`$ curl http://localhost:8080/`
------------------------------------------------*/

package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("received request")
		fmt.Fprintf(w, "Hello Docker!!\n")
	})

	log.Println("start server")
	server := &http.Server{Addr: ":8080"}
	if err := server.ListenAndServe(); err != nil {
		log.Println(err)
	}
}
