package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path"
	"strings"
	"text/template"

	"golang.org/x/crypto/bcrypt"

	"github.com/joho/godotenv"
)

type UserRequestBody struct {
	Username    string `json:"username"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"display_name"`
	IsActive    bool   `json:"is_active"`
}

var directory = ParentDirectoryOfThisFile()
var templates = template.Must(template.ParseFiles(path.Join(directory, "../template/swagger-ui.html")))
var db *Storage

func main() {
	// load environment variables
	err := godotenv.Load(path.Join(directory, "../.env"))
	if err != nil {
		panic("failed to load environment variables from .env")
	}
	db, err = InitStorage(os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed connecting to the database: %v\n", err)
		os.Exit(1)
	}

	mux := http.NewServeMux()

	static_dir := path.Join(directory, "../static")
	staticFileServer := http.FileServer(http.Dir(static_dir))
	mux.Handle("GET /static/", http.StripPrefix("/static", staticFileServer))

	mux.HandleFunc("GET /swagger", makeHandler(swaggerUIHandler))

	mux.HandleFunc("GET /api/v1/", makeHandler(indexHandler))

	mux.HandleFunc("GET /api/v1/users", makeHandler(fetchAllUsers))
	mux.HandleFunc("POST /api/v1/users", makeHandler(createSingleUser))
	mux.HandleFunc("GET /api/v1/users/{username}", makeHandler(fetchSingleUser))
	mux.HandleFunc("DELETE /api/v1/users/{username}", makeHandler(deleteSingleUser))
	mux.HandleFunc("PUT /api/v1/users/{username}", makeHandler(updateSingleUser))
	mux.HandleFunc("PATCH /api/v1/users/{username}", makeHandler(patchSingleUser))

	mux.HandleFunc("GET /api/v1/stores", makeHandler(fetchAllStores))
	mux.HandleFunc("GET /api/v1/stores/{slug}", makeHandler(fetchSingleStore))
	mux.HandleFunc("DELETE /api/v1/stores/{slug}", makeHandler(deleteSingleStore))
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
	result, err := db.GetAllUsers()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func createSingleUser(w http.ResponseWriter, r *http.Request) error {
	var user UserRequestBody
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		return DetailedError(err)
	}

	var errMsgBuilder strings.Builder
	if user.Username == "" {
		errMsgBuilder.WriteString("username")
	}
	if user.Email == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", email")
		} else {
			errMsgBuilder.WriteString("email")
		}
	}
	if user.Password == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", password")
		} else {
			errMsgBuilder.WriteString("password")
		}
	}
	if user.DisplayName == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", display_name")
		} else {
			errMsgBuilder.WriteString("display_name")
		}
	}
	if errMsgBuilder.Len() != 0 {
		return fmt.Errorf("%s field(s) must be provided.", errMsgBuilder.String())
	}

	password_hash, err := bcrypt.GenerateFromPassword([]byte(user.Password), 10)
	if err != nil {
		return DetailedError(err)
	}
	user.Password = string(password_hash)

	result, err := db.CreateSingleUser(user)
	if err != nil {
		return DetailedError(err)
	}
	if result.Username == "" {
		http.NotFound(w, r)
		return nil
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func fetchSingleUser(w http.ResponseWriter, r *http.Request) error {
	username := r.PathValue("username")
	result, err := db.GetSingleUser(username)
	if err != nil {
		return DetailedError(err)
	}
	if result.Username == "" {
		http.NotFound(w, r)
		return nil
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func deleteSingleUser(w http.ResponseWriter, r *http.Request) error {
	username := r.PathValue("username")
	result, err := db.DeleteSingleUser(username)
	if err != nil {
		return DetailedError(err)
	}
	if result.Username == "" {
		http.NotFound(w, r)
		return nil
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func updateSingleUser(w http.ResponseWriter, r *http.Request) error {
	username := r.PathValue("username")

	var user UserRequestBody
	// NOTE(umut): if is_active is not provided it will be probably set to false
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		return DetailedError(err)
	}

	var errMsgBuilder strings.Builder
	if user.Username == "" {
		errMsgBuilder.WriteString("username")
	}
	if user.Email == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", email")
		} else {
			errMsgBuilder.WriteString("email")
		}
	}
	if user.Password == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", password")
		} else {
			errMsgBuilder.WriteString("password")
		}
	}
	if user.DisplayName == "" {
		if errMsgBuilder.Len() != 0 {
			errMsgBuilder.WriteString(", display_name")
		} else {
			errMsgBuilder.WriteString("display_name")
		}
	}
	if errMsgBuilder.Len() != 0 {
		return fmt.Errorf("%s field(s) must be provided.", errMsgBuilder.String())
	}

	password_hash, err := bcrypt.GenerateFromPassword([]byte(user.Password), 10)
	if err != nil {
		return DetailedError(err)
	}

	user.Password = string(password_hash)
	result, err := db.UpdateSingleUser(username, user)
	if err != nil {
		return DetailedError(err)
	}
	// TODO(umut): should handle this case better
	if result.Username == "" {
		http.NotFound(w, r)
		return nil
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func patchSingleUser(w http.ResponseWriter, r *http.Request) error {
	username := r.PathValue("username")

	var user UserRequestBody
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		return DetailedError(err)
	}

	if user.Password != "" {
		password_hash, err := bcrypt.GenerateFromPassword([]byte(user.Password), 10)
		if err != nil {
			return DetailedError(err)
		}
		user.Password = string(password_hash)
	}

	result, err := db.PatchSingleUser(username, user)
	if err != nil {
		return DetailedError(err)
	}
	// TODO(umut): should handle this case better
	if result.Username == "" {
		http.NotFound(w, r)
		return nil
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func fetchAllStores(w http.ResponseWriter, r *http.Request) error {
	result, err := db.GetAllStores()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func fetchSingleStore(w http.ResponseWriter, r *http.Request) error {
	slug := r.PathValue("slug")
	result, err := db.GetSingleStore(slug)
	if err != nil {
		return DetailedError(err)
	}
	if result.Slug == "" {
		http.NotFound(w, r)
		return nil
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func deleteSingleStore(w http.ResponseWriter, r *http.Request) error {
	slug := r.PathValue("slug")
	result, err := db.DeleteSingleStore(slug)
	if err != nil {
		return DetailedError(err)
	}
	if result.Slug == "" {
		http.NotFound(w, r)
		return nil
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
	if err != nil {
		return err
	}
	return nil
}

func fetchUsersAndStores(w http.ResponseWriter, r *http.Request) error {
	result, err := db.GetAllUserStores()
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(result)
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
