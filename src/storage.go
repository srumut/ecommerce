package main

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"database/sql"

	"github.com/jackc/pgx/v5/pgconn"
	_ "github.com/jackc/pgx/v5/stdlib"
)

type Storage struct {
	db *sql.DB
}

type User struct {
	Username    string    `json:"username"`
	Email       string    `json:"email"`
	DisplayName string    `json:"display_name"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// TODO(umut): add updated at ?
type Store struct {
	Name        string
	Slug        string
	Description string
	CreatedAt   time.Time
}

type UserStores struct {
	User   User
	Stores []Store
}

// TODO(umut): maybe change this value to a more fine tuned one, or specify a value for each function ?
const SliceCap uint32 = 0
const UniqueViolation string = "23505"

func InitStorage(databaseUrl string) (*Storage, error) {
	// connect to the database
	db, err := sql.Open("pgx", databaseUrl)
	if err != nil {
		return nil, err
	}
	// configure the pool
	db.SetMaxOpenConns(20)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(time.Hour)
	return &Storage{db}, nil
}

func (s *Storage) GetAllUsers() ([]User, error) {
	query := `SELECT username,
					 email,
					 display_name,
					 is_active,
					 created_at,
					 updated_at
			  FROM users;`
	rows, err := s.db.Query(query)
	if err != nil {
		return nil, DetailedError(convertPgError(err))
	}
	defer rows.Close()

	result := make([]User, 0, SliceCap)
	for rows.Next() {
		var user User
		err = rows.Scan(
			&user.Username,
			&user.Email,
			&user.DisplayName,
			&user.IsActive,
			&user.CreatedAt,
			&user.UpdatedAt)
		if err != nil {
			return nil, DetailedError(convertPgError(err))
		}

		result = append(result, user)
	}

	return result, nil
}

// NOTE(umut): assumes the user.Password is hashed (it will not hash it itself)
func (s *Storage) CreateSingleUser(user UserRequestBody) (User, error) {
	var result User
	query := `INSERT INTO users (username, email, password_hash, display_name, is_active)
			  VALUES ($1, $2, $3, $4, $5)
			  RETURNING username, email, display_name, is_active, created_at, updated_at;`
	row := s.db.QueryRow(query,
		user.Username,
		user.Email,
		user.Password,
		user.DisplayName,
		user.IsActive)
	err := row.Scan(
		&result.Username,
		&result.Email,
		&result.DisplayName,
		&result.IsActive,
		&result.CreatedAt,
		&result.UpdatedAt)
	if err == sql.ErrNoRows {
		return result, nil
	} else if err != nil {
		return result, DetailedError(convertPgError(err))
	}

	return result, nil
}

func (s *Storage) GetSingleUser(username string) (User, error) {
	var result User
	query := `SELECT username,
					 email,
					 display_name,
					 is_active,
					 created_at,
					 updated_at
			  FROM users WHERE username = $1;`
	rows, err := s.db.Query(query, username)
	if err != nil {
		return result, DetailedError(convertPgError(err))
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(
			&result.Username,
			&result.Email,
			&result.DisplayName,
			&result.IsActive,
			&result.CreatedAt,
			&result.UpdatedAt)
		if err != nil {
			return result, DetailedError(convertPgError(err))
		}
	}

	return result, nil
}

func (s *Storage) DeleteSingleUser(username string) (User, error) {
	var result User
	query := `DELETE FROM users WHERE username = $1
			  RETURNING username, email, display_name, is_active, created_at, updated_at;`
	row := s.db.QueryRow(query, username)
	err := row.Scan(
		&result.Username,
		&result.Email,
		&result.DisplayName,
		&result.IsActive,
		&result.CreatedAt,
		&result.UpdatedAt)
	if err == sql.ErrNoRows {
		return result, nil
	} else if err != nil {
		return result, DetailedError(convertPgError(err))
	}

	return result, nil
}

func (s *Storage) UpdateSingleUser(username string, user UserRequestBody) (User, error) {
	var result User
	query := `UPDATE users SET username = $1,
							   email = $2,
							   display_name = $3,
							   is_active = $4
			  WHERE username = $5
			  RETURNING username, email, display_name, is_active, created_at, updated_at;`
	row := s.db.QueryRow(query,
		user.Username,
		user.Email,
		user.DisplayName,
		user.IsActive,
		username)
	err := row.Scan(
		&result.Username,
		&result.Email,
		&result.DisplayName,
		&result.IsActive,
		&result.CreatedAt,
		&result.UpdatedAt)
	if err == sql.ErrNoRows {
		return result, nil
	} else if err != nil {
		return result, DetailedError(convertPgError(err))
	}

	return result, nil
}

func (s *Storage) PatchSingleUser(username string, user UserRequestBody) (User, error) {
	var result User
	var queryBuilder strings.Builder
	values := []any{}

	queryBuilder.WriteString("UPDATE users SET is_active = $1")
	values = append(values, user.IsActive)
	if user.Username != "" {
		values = append(values, user.Username)
		queryBuilder.WriteString(fmt.Sprintf(", username = $%d", len(values)))
	}
	if user.Email != "" {
		values = append(values, user.Email)
		queryBuilder.WriteString(fmt.Sprintf(", email = $%d", len(values)))
	}
	if user.Password != "" {
		values = append(values, user.Password)
		queryBuilder.WriteString(fmt.Sprintf(", password = $%d", len(values)))
	}
	if user.DisplayName != "" {
		values = append(values, user.DisplayName)
		queryBuilder.WriteString(fmt.Sprintf(", display_name = $%d", len(values)))
	}
	values = append(values, username)
	queryBuilder.WriteString(fmt.Sprintf(" WHERE username = $%d RETURNING username, email, display_name, is_active, created_at, updated_at;", len(values)))
	query := queryBuilder.String()
	fmt.Println(query)
	fmt.Printf("%+v\n", values)
	row := s.db.QueryRow(query, values...)
	err := row.Scan(
		&result.Username,
		&result.Email,
		&result.DisplayName,
		&result.IsActive,
		&result.CreatedAt,
		&result.UpdatedAt)
	if err == sql.ErrNoRows {
		return result, nil
	} else if err != nil {
		return result, DetailedError(convertPgError(err))
	}

	return result, nil
}

// TODO(umut): query filtering (fields to return, number of objects to return and etc.)
func (s *Storage) GetAllStores() ([]Store, error) {
	query := `SELECT name,
					 slug,
					 description,
					 created_at
			  FROM stores;`
	rows, err := s.db.Query(query)
	if err != nil {
		return nil, DetailedError(convertPgError(err))
	}
	defer rows.Close()

	result := make([]Store, 0, SliceCap)
	for rows.Next() {
		var store Store
		err = rows.Scan(
			&store.Name,
			&store.Slug,
			&store.Description,
			&store.CreatedAt)
		if err != nil {
			return nil, DetailedError(convertPgError(err))
		}

		result = append(result, store)
	}

	return result, nil
}

func (s *Storage) GetSingleStore(slug string) (Store, error) {
	var result Store
	query := `SELECT name,
					 slug,
					 description,
					 created_at
			  FROM stores WHERE slug = $1;`
	rows, err := s.db.Query(query, slug)
	if err != nil {
		return result, DetailedError(convertPgError(err))
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(
			&result.Name,
			&result.Slug,
			&result.Description,
			&result.CreatedAt)
		if err != nil {
			return result, DetailedError(convertPgError(err))
		}
	}

	return result, nil
}

func (s *Storage) DeleteSingleStore(slug string) (Store, error) {
	var result Store
	query := `DELETE FROM stores WHERE slug = $1
			  RETURNING name, slug, description, created_at;`
	row := s.db.QueryRow(query, slug)
	err := row.Scan(
		&result.Name,
		&result.Slug,
		&result.Description,
		&result.CreatedAt)
	if err == sql.ErrNoRows {
		return result, nil
	} else if err != nil {
		return result, DetailedError(convertPgError(err))
	}

	return result, nil
}

// TODO(umut): query filtering (fields to return, number of objects to return and etc.)
func (s *Storage) GetAllUserStores() ([]UserStores, error) {
	query := `SELECT u.id,
					 u.username,
					 u.email,
					 u.display_name,
					 u.is_active,
					 u.created_at,
					 u.updated_at,
			         s.name,
			         s.slug,
			         s.description,
			         s.created_at
			  FROM users u INNER JOIN stores s ON u.id = s.owner_user_id
			  ORDER BY u.id ASC;`

	rows, err := s.db.Query(query)
	if err != nil {
		return nil, DetailedError(convertPgError(err))
	}
	defer rows.Close()

	result := make([]UserStores, 0, SliceCap)
	var prevUserId int64 = -1
	var userId int64 = -1
	var user User
	var store Store
	var stores []Store = make([]Store, 0, 1)
	var userStores UserStores

	for rows.Next() {
		err = rows.Scan(
			&userId,
			&user.Username,
			&user.Email,
			&user.DisplayName,
			&user.IsActive,
			&user.CreatedAt,
			&user.UpdatedAt,
			&store.Name,
			&store.Slug,
			&store.Description,
			&store.CreatedAt)
		if err != nil {
			return nil, DetailedError(convertPgError(err))
		}

		if userId == prevUserId || prevUserId == -1 {
			userStores.User = user
			stores = append(stores, store)
			prevUserId = userId
		} else {
			// handle the previous user and its stores
			userStores.Stores = make([]Store, len(stores))
			copy(userStores.Stores, stores)
			stores = stores[:0] // reset slice's length
			result = append(result, userStores)

			// handle the new user
			userStores.User = user
			stores = append(stores, store)
			prevUserId = userId
		}
	}

	// if there were more than one user with stores
	// TODO(umut): this might me redundant to check (since a real application would have thousands) ?
	if prevUserId != -1 {
		copy(userStores.Stores, stores)
		result = append(result, userStores)
	}

	return result, nil
}

type DatabaseError struct {
	Field   string
	Message string
}

func (err DatabaseError) Error() string {
	return err.Message
}

func convertPgError(err error) error {
	var pgErr *pgconn.PgError

	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case UniqueViolation:
			field := strings.Split(pgErr.ConstraintName, "_")[1]
			if pgErr.ColumnName != "" {
				fmt.Printf("Column name: %s\n", pgErr.ColumnName)
				field = pgErr.ColumnName
			}
			msg := fmt.Sprintf("%s is taken, it must be unique", field)
			return DatabaseError{Field: field, Message: msg}
		}
	}
	return err
}
