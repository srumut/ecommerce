package storage

import (
	"time"

	"database/sql"

	"github.com/srumut/ecommerce/utility"
)

type Storage struct {
	db *sql.DB
}

// TODO(umut):
// not all fields should be returned, for example password
// hash and id should not be visible outside of the package?

type User struct {
	Username    string
	Email       string
	DisplayName string
	IsActive    bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
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

// TODO(umut): query filtering (fields to return, number of objects to return and etc.)
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
		return nil, err
	}
	defer rows.Close()

	users := make([]User, 0, SliceCap)
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
			return nil, err
		}

		users = append(users, user)
	}

	return users, nil
}

func (s *Storage) GetSingleUser(username string) (User, error) {
	var user User
	query := `SELECT username,
					 email,
					 display_name,
					 is_active,
					 created_at,
					 updated_at
			  FROM users WHERE username = $1;`
	rows, err := s.db.Query(query, username)
	if err != nil {
		return user, utility.DetailedError(err)
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(
			&user.Username,
			&user.Email,
			&user.DisplayName,
			&user.IsActive,
			&user.CreatedAt,
			&user.UpdatedAt)
		if err != nil {
			return user, utility.DetailedError(err)
		}
	}

	return user, nil
}

func (s *Storage) DeleteSingleUser(username string) (User, error) {
	var user User
	query := `DELETE FROM users WHERE username = $1
			  RETURNING username, email, display_name, is_active, created_at, updated_at;`
	row := s.db.QueryRow(query, username)
	err := row.Scan(
		&user.Username,
		&user.Email,
		&user.DisplayName,
		&user.IsActive,
		&user.CreatedAt,
		&user.UpdatedAt)
	if err == sql.ErrNoRows {
		return user, nil
	} else if err != nil {
		return user, utility.DetailedError(err)
	}

	return user, nil
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
		return nil, err
	}
	defer rows.Close()

	stores := make([]Store, 0, SliceCap)
	for rows.Next() {
		var store Store
		err = rows.Scan(
			&store.Name,
			&store.Slug,
			&store.Description,
			&store.CreatedAt)
		if err != nil {
			return nil, err
		}

		stores = append(stores, store)
	}

	return stores, nil
}

func (s *Storage) GetSingleStore(slug string) (Store, error) {
	var store Store
	query := `SELECT name,
					 slug,
					 description,
					 created_at
			  FROM stores WHERE slug = $1;`
	rows, err := s.db.Query(query, slug)
	if err != nil {
		return store, utility.DetailedError(err)
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(
			&store.Name,
			&store.Slug,
			&store.Description,
			&store.CreatedAt)
		if err != nil {
			return store, utility.DetailedError(err)
		}
	}

	return store, nil
}

func (s *Storage) DeleteSingleStore(slug string) (Store, error) {
	var store Store
	query := `DELETE FROM stores WHERE slug = $1
			  RETURNING name, slug, description, created_at;`
	row := s.db.QueryRow(query, slug)
	err := row.Scan(
		&store.Name,
		&store.Slug,
		&store.Description,
		&store.CreatedAt)
	if err == sql.ErrNoRows {
		return store, nil
	} else if err != nil {
		return store, utility.DetailedError(err)
	}

	return store, nil
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
		return nil, err
	}
	defer rows.Close()

	usersAndTheirStores := make([]UserStores, 0, SliceCap)
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
			return nil, err
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
			usersAndTheirStores = append(usersAndTheirStores, userStores)

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
		usersAndTheirStores = append(usersAndTheirStores, userStores)
	}

	return usersAndTheirStores, nil
}
