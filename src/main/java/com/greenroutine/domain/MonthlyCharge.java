package com.greenroutine.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@Table(
        name = "monthly_charge",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "ym"})
)
public class MonthlyCharge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    private String ym;
    // 연-월, 서비스랑 컨트롤러 만들고 처리할 예정입니당

    @Column(nullable = false)
    private int elec;
    // 전기 요금(원) — 도넛1

    @Column(nullable = false)
    private int gas;
    // 가스 요금(원) — 도넛2



    // 총 관리비
    @Transient
    public int getTotal() {
        return Math.max(0, elec) + Math.max(0, gas);
    }

    // 전기 비율
    @Transient
    public double getElecRatio() {
        int total = getTotal();
        return total == 0 ? 0.0 : (double) Math.max(0, elec) / total;
    }

    // 가스 비율
    @Transient
    public double getGasRatio() {
        int total = getTotal();
        return total == 0 ? 0.0 : (double) Math.max(0, gas) / total;
    }
}
