package com.douradelivery.repository;

import com.douradelivery.model.Document;
import com.douradelivery.model.Document.DocumentStatus;
import com.douradelivery.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {
    
    List<Document> findByUser(User user);
    
    List<Document> findByUserOrderBySubmittedAtDesc(User user);
    
    List<Document> findByStatus(DocumentStatus status);
    
    @Query("SELECT d FROM Document d WHERE d.status = :status ORDER BY d.submittedAt ASC")
    List<Document> findByStatusOrderBySubmittedAtAsc(@Param("status") DocumentStatus status);
    
    @Query("SELECT d FROM Document d JOIN FETCH d.user WHERE d.status = 'PENDING' ORDER BY d.submittedAt ASC")
    List<Document> findPendingDocumentsWithUser();
    
    @Query("SELECT d FROM Document d WHERE d.user.id = :userId AND d.status = :status")
    List<Document> findByUserIdAndStatus(@Param("userId") Long userId, @Param("status") DocumentStatus status);
    
    @Query("SELECT CASE WHEN COUNT(d) > 0 THEN true ELSE false END FROM Document d WHERE d.user.id = :userId")
    boolean existsByUserId(@Param("userId") Long userId);
    
    @Query("SELECT d FROM Document d WHERE d.user.id = :userId ORDER BY d.submittedAt DESC")
    List<Document> findByUserIdOrderBySubmittedAtDesc(@Param("userId") Long userId);
    
    Optional<Document> findFirstByUserOrderBySubmittedAtDesc(User user);
}
