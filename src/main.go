package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"text/template"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"

	"github.com/srumut/ecommerce/storage"
	"github.com/srumut/ecommerce/utility"
)

var templates = template.Must(template.ParseFiles("./template/swagger-ui.html"))
var db *storage.Storage

func main() {
	// load environment variables
	err := godotenv.Load("./.env")
	if err != nil {
		panic("failed to load environment variables from .env")
	}
	db, err = storage.InitStorage(os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed connecting to the database: %v\n", err)
		os.Exit(1)
	}

	mux := http.NewServeMux()

	staticFileServer := http.FileServer(http.Dir("./static"))
	mux.Handle("GET /static/", http.StripPrefix("/static", staticFileServer))

	mux.HandleFunc("GET /swagger", makeHandler(swaggerUIHandler))

	mux.HandleFunc("GET /api/v1/", makeHandler(indexHandler))
	mux.HandleFunc("GET /api/v1/users", makeHandler(fetchAllUsers))
	mux.HandleFunc("GET /api/v1/users/{username}", makeHandler(fetchSingleUser))
	mux.HandleFunc("GET /api/v1/stores", makeHandler(fetchAllStoers))
	mux.HandleFunc("GET /api/v1/users/stores", makeHandler(fetchUsersAndStores))

	server := http.Server{Addr: ":8080", Handler: mux}
	log.Fatal(server.ListenAndServe())
}

func makeHandler(fn func(http.ResponseWriter, *http.Request) error) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := fn(w, r)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			log.Print(err)
		}
	}
}

func fetchAllUsers(w http.ResponseWriter, r *http.Request) error {
	users, err := db.GetAllUsers()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(users)
	if err != nil {
		return err
	}
	return nil
}

func fetchSingleUser(w http.ResponseWriter, r *http.Request) error {
	username := r.PathValue("username")
	user, err := db.GetSingleUser(username)
	if err != nil {
		return utility.DetailedError(err)
	}
	if user.Username == "" {
		http.NotFound(w, r)
		return nil
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(user)
	if err != nil {
		return err
	}
	return nil
}

func fetchAllStoers(w http.ResponseWriter, r *http.Request) error {
	stores, err := db.GetAllStores()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(stores)
	if err != nil {
		return err
	}
	return nil
}

func fetchUsersAndStores(w http.ResponseWriter, r *http.Request) error {
	userStores, err := db.GetAllUserStores()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(userStores)
	if err != nil {
		return err
	}
	return nil
}

func indexHandler(w http.ResponseWriter, r *http.Request) error {
	fmt.Fprintf(w, "this is ecommerce api version 1")
	return nil
}

func swaggerUIHandler(w http.ResponseWriter, r *http.Request) error {
	err := templates.ExecuteTemplate(w, "swagger-ui.html", nil)
	if err != nil {
		return err
	}
	return nil
}
